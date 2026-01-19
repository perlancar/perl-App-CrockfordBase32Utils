package App::CrockfordBase32Utils;

use 5.010001;
use strict 'subs', 'vars';
use utf8;
use warnings;
use Log::ger;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(
                       num_to_cfbase32
                       cfbase32_to_num
                       cfbase32_encode
                       cfbase32_decode
               );

our %SPEC;

$SPEC{num_to_cfbase32} = {
    v => 1.1,
    summary => "Convert an integer decimal number to Crockford's Base 32 encoding",
    args => {
        num => {
            schema => 'int*',
            pos => 0,
            cmdline_src => 'stdin_or_args',
        },
    },
};
sub num_to_cfbase32 {
    require Encode::Base32::Crockford;

    defined(my $num = $args{num}) or return [400, "Please specify number"];
    $num = int($num);

    [200, "OK", Encode::Base32::Crockford::base32_encode($num)];
}

$SPEC{cfbase32_to_num} = {
    v => 1.1,
    summary => "Convert Crockford's Base 32 encoding to integer decimal number",
    args => {
        str => {
            schema => 'str*',
            pos => 0,
            cmdline_src => 'stdin_or_args',
        },
    },
};
sub num_to_cfbase32 {
    require Encode::Base32::Crockford;

    defined(my $str = $args{str}) or return [400, "Please specify Base 32 number"];

    [200, "OK", Encode::Base32::Crockford::base32_decode($str)];
}


1;
# ABSTRACT: Utilities related to Crockford's Base 32 encoding

=head1 DESCRIPTION

This distribution contains the following CLIs:

# INSERT_EXECS_LIST

Keywords: base32, base 32, crockford's base 32


=head1 SEE ALSO

L<https://www.crockford.com/base32.html>
