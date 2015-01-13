package MT::SimpleOrder::L10N::ja;

use strict;
use utf8;
use base 'MT::SimpleOrder::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (

    'Manages simple display order of entries and pages.'
        => '記事とウェブページの順番を簡易的に管理します。',
    'Simple Order' => '順番',
    'Set Order' => '順番を設定',
    'Reset Order' => '順番をリセット',
    'Enter integer order value' => '順番を入力してください。',
    'Enter a positive integer as order value.' => '0以上の整数による順番を入力してください',
    'Successfully reset order value of [_1] object(s).'
        => '[_1]件の優先度をリセットしました',
    'Successfully set order value of [_1] object(s) to [_2].'
        => '[_1]件の順番を[_2]に設定しました',

);

1;

