package MT::SimpleOrder::Listing;

use strict;
use warnings;

use MT::SimpleOrder::Util;

our %objects = (
    entry => {
        code => \&action_set_entry_order,
        permit_action => {
            permit_action => 'edit_all_entries',
            at_least_one => 1,
        },
    },
    page => {
        code => \&action_set_page_order,
        permit_action => {
            permit_action => 'edit_pages',
            at_least_one => 1,
        },
    },
);

sub _object_prop {
    my ( $type, $args ) = @_;

    {
        simple_order => {
            label     => 'Simple Order',
            col_class => 'id',
            base      => '__virtual.integer',
            display   => MT->instance->config('SimpleOrderDisplay') || 'default',
            col       => 'simple_order',
            order     => MT->instance->config('SimpleOrderOrder') || 2000,
        },
    };
}

sub properties {
    my %props = map {
        $_ => _object_prop($_, $objects{$_})
    } keys %objects;

    \%props;
}

sub _object_action {
    my ( $type, $args ) = @_;

    {
        set_simple_order => {
            label => 'Set Order',
            order => 2000,
            code => $args->{code},
            input => 1,
            input_label => 'Enter integer order value',
            permit_action => $args->{permit_action},
        },
        reset_simple_order => {
            label => 'Reset Order',
            order => 2100,
            code => $args->{code},
            permit_action => $args->{permit_action},
        },
    }
}

sub actions {
    my %actions = map {
        $_ => _object_action($_, $objects{$_})
    } keys %objects;

    \%actions;
}

sub _is_user_editable_object {
    my ( $user, $type, $obj ) = @_;
    return 1 if $user->is_superuser;

    my @blog_ids = $obj->can('blog_id') ? (0, $obj->blog_id) : (0);
    my $permit_action = $objects{$type}->{permit_action};

    $user->can_do($permit_action, at_least_one => 1, blog_id => \@blog_ids);
}

sub _return_list_action {
    my ( $app, $xhr, %opts ) = @_;
    if ( my $return_args = $opts{return_args} ) {
        $app->add_return_arg( %$return_args );
    }
    return $xhr
        ? {
            messages => [
                {
                    cls => $opts{cls},
                    msg => $opts{msg},
                }
            ]
        }
        : $app->call_return;
}

sub _action_set_order {
    my $type = shift;
    my $object = $objects{$type};

    my $app = shift;
    $app->validate_magic or return;
    my $user = $app->user;

    my $xhr = $app->param('xhr');
    my @id = $app->param('id');
    my $value = $app->param('itemset_action_input');
    $value =~ s/^\s+|\s+$//g;
    my $order = defined($value) && $value ne '' ? int($value) : undef;

    _return_list_action( $app, $xhr,
        return_args => {
            simple_order_not_integer => 1,
        },
        cls => 'error',
        msg => plugin->translate(
            'Enter a positive integer as order value.',
        ),
    ) if defined($order) && $order ne $value;

    my @objects = MT->model($type)->load({id => \@id});
    my $set_count = 0;
    foreach my $obj ( @objects ) {
        next unless _is_user_editable_object($user, $type, $obj);
        $obj->simple_order($order);
        $obj->save or next;
        $set_count ++;
    }

    if ( defined($order) ) {
        _return_list_action( $app, $xhr,
            return_args => {
                simple_order_set => $set_count,
                simple_order_value => $value,
            },
            cls => 'success',
            msg => plugin->translate(
                'Successfully set order value of [_1] object(s) to [_2].',
                $set_count, $order
            ),
        );
    } else {
        _return_list_action( $app, $xhr,
            return_args => {
                simple_order_reset => $set_count,
            },
            cls => 'success',
            msg => plugin->translate(
                'Successfully reset order value of [_1] object(s).',
                $set_count
            ),
        );
    }
}

sub action_set_entry_order {
    _action_set_order('entry', @_);
}

sub action_set_page_order {
    _action_set_order('page', @_);
}

sub template_param_list_common {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $include = $tmpl->getElementById('header_include');
    my $node = $tmpl->createElement('setvarblock', { name => 'system_msg', append => 1 });
    $node->innerHTML(q(
        <__trans_section component="SimpleOrder">
        <mt:if name="simple_order_not_integer">
            <mtapp:statusmsg
                id="simple-order-not-integer"
                class="error">
                <__trans phrase="Enter a positive integer as order value.">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="simple_order_set">
            <mtapp:statusmsg
                id="simple-order-set"
                class="success">
                <__trans phrase="Successfully set order value of [_1] object(s) to [_2]." params="<mt:var name='simple_order_set' />%%<mt:var name='simple_order_value' />">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="simple_order_reset">
            <mtapp:statusmsg
                id="simple-order-reset"
                class="success">
                <__trans phrase="Successfully reset order value of [_1] object(s)." params="<mt:var name='simple_order_reset' />">
            </mtapp:statusmsg>
        </mt:if>
        </__trans_section>
    ));
    $tmpl->insertBefore($node, $include);

    foreach my $key ( qw(set value reset not_integer) ) {
        my $p = "simple_order_$key";
        $param->{$p} = $app->param($p);
    }

    1;
}

1;