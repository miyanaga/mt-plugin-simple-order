package MT::Plugin::Priority::Listing;

use strict;
use warnings;

use MT::Plugin::Priority::Util;

our %objects = (
    entry => {
        code => \&action_set_entry_priority,
        permit_action => {
            permit_action => 'edit_all_entries',
            at_least_one => 1,
        },
    },
);

sub _object_prop {
    my ( $type, $args ) = @_;

    {
        priority_value => {
            label     => 'Priority Value',
            base      => '__virtual.integer',
            display   => 'force',
            col       => 'priority_value',
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
        set_priority_value => {
            label => 'Set Priority',
            order => 2000,
            code => $args->{code},
            input => 1,
            input_label => 'Enter priority integer value',
            permit_action => $args->{permit_action},
        },
        reset_priority_value => {
            label => 'Reset Priority',
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

sub _action_set_priority {
    my $type = shift;
    my $object = $objects{$type};

    my $app = shift;
    $app->validate_magic or return;
    my $user = $app->user;

    my $xhr = $app->param('xhr');
    my @id = $app->param('id');
    my $value = $app->param('itemset_action_input');
    $value =~ s/^\s+|\s+$//g;
    pp($value);
    my $priority = defined($value) && $value ne '' ? int($value) : undef;

    _return_list_action( $app, $xhr,
        return_args => {
            priority_not_integer => 1,
        },
        cls => 'error',
        msg => plugin->translate(
            'Enter a positive integer as priority value.',
        ),
    ) if defined($priority) && $priority ne $value;

    my @objects = MT->model($type)->load({id => \@id});
    my $set_count = 0;
    foreach my $obj ( @objects ) {
        next unless _is_user_editable_object($user, $type, $obj);
        $obj->priority_value($priority);
        $obj->save or next;
        $set_count ++;
    }

    if ( defined($priority) ) {
        _return_list_action( $app, $xhr,
            return_args => {
                priority_set => $set_count,
                priority_value => $value,
            },
            cls => 'success',
            msg => plugin->translate(
                'Successfully set priority value of [_1] object(s) to [_2].',
                $set_count, $priority
            ),
        );
    } else {
        _return_list_action( $app, $xhr,
            return_args => {
                priority_reset => $set_count,
            },
            cls => 'success',
            msg => plugin->translate(
                'Successfully reset priority value of [_1] object(s).',
                $set_count
            ),
        );
    }
}

sub action_set_entry_priority {
    _action_set_priority('entry', @_);
}

sub template_param_list_common {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $include = $tmpl->getElementById('header_include');
    my $node = $tmpl->createElement('setvarblock', { name => 'system_msg', append => 1 });
    $node->innerHTML(q(
        <__trans_section component="Priority">
        <mt:if name="priority_not_integer">
            <mtapp:statusmsg
                id="priority-not-integer"
                class="error">
                <__trans phrase="Enter a positive integer as priority value.">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="priority_set">
            <mtapp:statusmsg
                id="priority-set-priority"
                class="success">
                <__trans phrase="Successfully set priority value of [_1] object(s) to [_2]." params="<mt:var name='priority_set' />%%<mt:var name='priority_value' />">
            </mtapp:statusmsg>
        </mt:if>
        <mt:if name="priority_reset">
            <mtapp:statusmsg
                id="priority-reset-priority"
                class="success">
                <__trans phrase="Successfully reset priority value of [_1] object(s)." params="<mt:var name='priority_reset' />">
            </mtapp:statusmsg>
        </mt:if>
        </__trans_section>
    ));
    $tmpl->insertBefore($node, $include);

    foreach my $key ( qw(set value reset not_integer) ) {
        my $p = "priority_$key";
        $param->{$p} = $app->param($p);
    }

    1;
}

1;