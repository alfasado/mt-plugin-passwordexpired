package PasswordExpired::L10N::ja;
use strict;
use base 'PasswordExpired::L10N';
use vars qw( %Lexicon );

our %Lexicon = (
    'Set the password expiration settings.' => 'パスワードの有効期限を設定します。',
    'Password Expired' => 'パスワード有効期限',
    'Your password was last changed at [_1]. Please <a href="[_2]?__mode=view&amp;_type=author&amp;id=[_3]">change your password</a> periodically.' => 'ログインパスワードが最後に変更されたのは [_1] です。定期的に<a href="[_2]?__mode=view&amp;_type=author&amp;id=[_3]">パスワードを変更</a>してください。',
    '<span style="color:gray">(Your password was last changed at [_1].)</span>' => '<span style="color:gray">(パスワードが最後に変更されたのは [_1] です)</span>',
);

1;