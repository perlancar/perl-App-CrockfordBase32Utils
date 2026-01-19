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
    summary => "Convert integer decimal number(s) to Crockford's Base 32 encoding",
    args => {
        nums => {
            schema => ['array*', of=>'int*'],
            pos => 0,
            slurpy => 1,
        },
    },
};
sub num_to_cfbase32 {
    require Encode::Base32::Crockford;

    my %args = @_;
    my $nums;
    defined($nums = $args{nums}) && @$nums or return [400, "Please specify one or more numbers"];

    my @res;
    for my $num (@{ $nums }) {
        $num = int($num);
        push @res, Encode::Base32::Crockford::base32_encode($num);
    }
    [200, "OK", \@res];
}

$SPEC{cfbase32_to_num} = {
    v => 1.1,
    summary => "Convert Crockford's Base 32 encoding to integer decimal number",
    args => {
        strs => {
            schema => ['array*', of=>'int*'],
            pos => 0,
            slurpy => 1,
        },
    },
};
sub cfbase32_to_num {
    require Encode::Base32::Crockford;

    my %args = @_;
    my $strs;
    defined($strs = $args{strs}) && @$strs or return [400, "Please specify one or more Base32 encoded strings"];

    my @res;
    for my $str (@{ $strs }) {
        push @res, Encode::Base32::Crockford::base32_decode($str);
    }
    [200, "OK", \@res];
}

$SPEC{cfbase32_encode} = {
    v => 1.1,
    summary => "Encode string to Crockford's Base32 encoding",
    args => {
        str => {
            schema => 'str*',
            pos => 0,
            cmdline_src => 'stdin_or_files',
        },
    },
};
sub cfbase32_encode {
    require Convert::Base32::Crockford;

    my %args = @_;
    my $str = $args{str};

    [200, "OK", Convert::Base32::Crockford::encode_base32($str)];
}

$SPEC{cfbase32_decode} = {
    v => 1.1,
    summary => "Decode Crockford's Base32 encoding",
    args => {
        str => {
            schema => 'str*',
            pos => 0,
            cmdline_src => 'stdin_or_files',
        },
    },
};
sub cfbase32_decode {
    require Convert::Base32::Crockford;

    my %args = @_;
    my $str = $args{str};
    $str =~ s/[^A-TV-Z0-9]+//ig;

    [200, "OK", Convert::Base32::Crockford::decode_base32($str)];
}

1;
# ABSTRACT: Utilities related to Crockford's Base 32 encoding

=head1 DESCRIPTION

This distribution contains the following CLIs:

# INSERT_EXECS_LIST

Keywords: base32, base 32, crockford's base 32


=head1 SEE ALSO

L<https://www.crockford.com/base32.html>
