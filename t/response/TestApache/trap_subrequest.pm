package TestApache::trap_subrequest;

use strict;
use warnings FATAL => 'all';

use Apache::TrapSubRequest  ();
use Apache::RequestRec      ();
use Apache::RequestIO       ();

use APR::Table              ();

use Apache::Const   -compile => qw(OK DECLINED);

sub handler {
    my $r = shift;
    $r->content_type('text/plain');
    my $output;
    my $subr = $r->lookup_uri('/subreq_output');
    $subr->run_trapped(\$output);
    $output = "Below is the output of the subrequest.\n" . $output;
    use bytes;
    $r->headers_out->set('Content-Length', length($output));
    $r->print($output);
    Apache::OK;
}

1;
