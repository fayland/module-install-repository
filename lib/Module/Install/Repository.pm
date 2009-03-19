package Module::Install::Repository;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use base qw(Module::Install::Base);

sub auto_set_repository {
    my $self = shift;

    return unless $Module::Install::AUTHOR;

    my $repo = _find_repo();
    if ($repo) {
        $self->repository($repo);
    } else {
        warn "Cannot determine repository URL\n";
    }
}

sub _find_repo {
    if (-e ".git") {
        # TODO support remote besides 'origin'?
        if (`git remote show origin` =~ /URL: (.*)$/m) {
            # XXX Make it public clone URL, but this only works with github
            my $git_url = $1;
            $git_url =~ s![\w\-]+\@([^:]+):!git://$1/!;
            return $git_url;
        }
    } elsif (-e ".svn") {
        if (`svn info` =~ /URL: (.*)$/m) {
            return $1;
        }
    } elsif (-e "$ENV{HOME}/.svk") {
        # Is there an explicit way to check if it's an svk checkout?
        my $svk_info = `svk info` or return;
        SVK_INFO: {
            if ($svk_info =~ /Mirrored From: (.*), Rev\./) {
                return $1;
            }

            if ($svk_info =~ m!Merged From: (/mirror/.*), Rev\.!) {
                $svk_info = `svk info /$1` or return;
                redo SVK_INFO;
            }
        }

        return;
    }
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Module::Install::Repository - Automatically sets repository URL from svn/svk/Git checkout

=head1 SYNOPSIS

  # in Makefile.PL
  use Module::Install;
  auto_set_repository;

=head1 DESCRIPTION

Module::Install::Repository is a Module::Install plugin to
automatically figure out repository URL and set it via I<repository()>
which then will be added to resources under I<META.yaml>.

=head1 CAVEATS

The regular expression to rewrite Git repository URL to public clone
URL is dependent on the server side directory layout, which means this
module currently works only with github.com style.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Module::Install>

=cut
