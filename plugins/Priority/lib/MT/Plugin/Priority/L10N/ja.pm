package MT::Plugin::Priority::L10N::ja;

use strict;
use utf8;
use base 'MT::Plugin::Priority::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (

	'Priority Value' => '優先度',
	'Set Priority' => '優先度を設定',
    'Reset Priority' => '優先度をリセット',
	'Enter priority integer value' => '整数による優先度を入力してください',
	'Successfully set priority value of [_1] object(s) to [_2].'
		=> '[_1]件の優先度を[_2]に設定しました',
	'Successfully reset priority value of [_1] object(s).'
		=> '[_1]件の優先度をリセットしました',
	'Enter a positive integer as priority value.' => '優先度には0以上の整数を入力してください',

);

1;

