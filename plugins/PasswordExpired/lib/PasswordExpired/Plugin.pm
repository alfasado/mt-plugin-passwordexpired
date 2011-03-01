package PasswordExpired::Plugin;
use strict;
use MT::Util qw( format_ts ts2epoch offset_time_list );

sub _cb_post_save_author {
    my ( $cb, $obj, $original ) = @_;
    my $app = MT->instance;
    if ( $app->mode eq 'save' ) {
        if ( my $user = $app->user ) {
            if ( $app->param( 'old_pass' ) && $app->param( 'pass' ) && $app->param( 'pass_verify' ) ) {
                my @tl = offset_time_list( time );
                my $password_updated_on = sprintf '%04d%02d%02d%02d%02d%02d',
                                          $tl[5]+1900, $tl[4]+1, @tl[3,2,1,0];
                $user->password_updated_on( $password_updated_on );
                $user->save or die $user->errstr;
            }
        }
    }
    return 1;
}

sub _passwordexpired {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $user = $app->user;
    my $plugin = $app->component( 'PasswordExpired' );
    my $password_updated_on = $user->password_updated_on;
    if (! $password_updated_on ) {
        $password_updated_on = $user->created_on;
        $user->password_updated_on( $password_updated_on );
        $user->save or die $user->errstr;
    }
    my $period = $plugin->get_config_value( 'pass_period' );
    my $updated_ts = ts2epoch( undef, $password_updated_on );
    my $tz = $app->config( 'DefaultTimezone' );
    $tz = 0 unless $tz;
    my $mode = $app->mode;
    if ( ( $app->mode eq 'view' ) && ( $app->param( '_type' ) eq 'author' ) ) {
        $mode = 'edit_author';
    } elsif ( ( $app->mode eq 'save' ) && ( $app->param( '_type' ) eq 'author' ) ) {
        $mode = 'save_author';
    }
    my $since = ( ( time + 3600 * $tz ) - $updated_ts ) / 86400;
    $password_updated_on = format_ts( "%Y&#24180;%m&#26376;%d&#26085;", $password_updated_on, undef,
                           $user ? $user->preferred_language : undef );
    if ( $period < $since ) {
        if ( $app->config( 'PasswordExpired' ) ) {
            if ( ( $mode ne 'edit_author' ) && ( $mode ne 'save_author' ) ) {
                $app->redirect( $app->uri( mode => 'view', args => { _type => 'author', id => $user->id } ) );
            }
        }
        if ( $cb->method eq 'pre_run' ) {
            return;
        }
        my $innerHTML = $plugin->translate( 'Your password was last changed at [_1]. Please <a href="[_2]?__mode=view&amp;_type=author&amp;id=[_3]">change your password</a> periodically.',
                                            $password_updated_on , $app->script, $user->id );
        if ( $mode eq 'edit_author' ) {
            if (! $param->{ error } ) {
                $param->{ error } = 1;
                my $nodeset = $tmpl->getElementById( 'generic-error' );
                $nodeset->innerHTML( $innerHTML );
            }
        } else {
            if (! $param->{ permission } ) {
                $param->{ permission } = 1;
                my $nodeset = $tmpl->getElementById( 'permissions' );
                $nodeset->innerHTML( $innerHTML );
            }
        }
    }
    if ( $cb->method eq 'pre_run' ) {
        return;
    }
    if ( $mode eq 'edit_author' ) {
        my $nodeset = $tmpl->getElementById( 'show_password' );
        if ( $nodeset ) {
            my $inner = $nodeset->innerHTML();
            $nodeset->innerHTML( $inner . $plugin->translate( '<span style="color:gray">(Your password was last changed at [_1].)</span>', $password_updated_on ) );
        }
    }
}

1;