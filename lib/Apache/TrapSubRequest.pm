package Apache::TrapSubRequest;

use warnings FATAL => 'all';
use strict;

use mod_perl 1.99;

use Apache::RequestRec  ();
use Apache::RequestUtil ();
use Apache::SubRequest  ();
use Apache::Filter      ();
use Apache::Connection  ();
use Apache::Log         ();

use APR::Bucket         ();
use APR::Brigade        ();

use Carp                ();

use Apache::Const   -compile => qw(OK DECLINED HTTP_OK);
use APR::Const      -compile => qw(:common);

=head1 NAME

Apache::TrapSubRequest - Trap a lookup_file/lookup_uri into a scalar

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    # ...
    use Apache::TrapSubRequest  ();

    sub handler {
        my $r = shift;
        my $subr = $r->lookup_uri('/foo');
        my $data;
        $subr->run_trapped(\$data);
        # ...
        Apache::OK;
    }

=head1 WARNING

This software requires that the Apache API function C<ap_save_brigade> be 
exposed as C<Apache::Filter::save_brigade> with the parameters 
($f, $newbb, $bb, $pool). As of this writing (2005-02-11), this
functionality is not present in the core mod_perl 2.x distribution.

=head1 FUNCTIONS

=head2 run_trapped (\$data);

Run the output of a subrequest into a scalar reference.

=cut

sub Apache::SubRequest::run_trapped {
    my ($r, $sref) = @_;
    Carp::croak('Usage: $subr->run_trapped(\$data)') 
        unless ref $sref eq 'SCALAR';
    $r->add_output_filter(\&_filter);
    my $rv = $r->run;
    # now $r->pnotes should contain the concat'd brigade.
    my $bb = $r->pnotes(__PACKAGE__);
    $bb->flatten(my $data);
    $$sref = $data;
    $rv;
}

sub _filter {
    my ($f, $bb) = @_;
    my $r = $f->r;
    my $newbb;
    unless ($newbb = $r->pnotes(__PACKAGE__)) {
        $newbb = APR::Brigade->new($r->pool, $f->c->bucket_alloc);
        $r->pnotes(__PACKAGE__, $newbb);
    }
    my $rv = $f->save_brigade($newbb, $bb, $r->pool);
    return $rv unless $rv == APR::SUCCESS;
    Apache::OK;
}

=head1 AUTHOR

dorian taylor, C<< <dorian@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-apache-trapsubrequest@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 dorian taylor, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Apache::TrapSubRequest
