#!/usr/bin/perl -w	
# -*-perl-*-

use Test::More tests => 27;
use File::Compare;
use Data::Struct::Matfile;
use Math::Matrix;

$eg_dir     = "eg";
$data_dir   = "sample.001";
$ok_dir     = "ok_sample";
@out_files = qw(sample_02
		sample_10
		sample_13
		sample_16_acq0
		sample_16_acq1
		sample_17
		);
@out_exts = qw( mat hdr );
  
$tmp = system("perl bin/pvconv.pl $eg_dir/$data_dir -verbose -outdir $eg_dir");
is( $tmp, 0, 'pvconv.pl ran successfully' );

$mat_file = Data::Struct::Matfile->new();
foreach $out_file(@out_files) {
    foreach $ext(@out_exts) {
	$out_fname = "$eg_dir/$out_file.$ext";
	ok( (-e $out_fname), "$out_fname exists"); 
	$in_fname = "$eg_dir/$ok_dir/$out_file.$ext";
	if ($ext eq 'hdr') {
	    is( compare($out_fname, $in_fname),  0, "$in_fname, $out_fname are same"); 
	} else {
	    # Need to use mat utilities to deal with byte order
	    $mat_file->read_from($out_fname);
	    $M1 = Math::Matrix->new(@{$mat_file->matrix()});
	    $mat_file->read_from($in_fname);
	    $M2 = Math::Matrix->new(@{$mat_file->matrix()});
	    is( $M1->equal($M2), 1, "$in_fname, $out_fname have same matrix");
	}
    }
}
	
$tmp = system('perl bin/pvshow.pl eg/sample.001');
is( $tmp, 0, 'running pvshow.pl' );

$tmp = system('perl bin/brk2mat.pl eg/sample_02.brkhdr');
is( $tmp, 0, 'running brk2mat' );

unlink <eg/sample_*>;
