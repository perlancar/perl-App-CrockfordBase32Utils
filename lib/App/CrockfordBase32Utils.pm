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
                       cfbase32_rand
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
            schema => ['array*', of=>'str*'],
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

my @cfbase32_digits = qw(0 1 2 3 4 5 6 7 8 9
                         A B C D E F G H J K
                         M N P Q R S T V W X Y Z);
my @cfbase32_digits_x0 = qw(1 2 3 4 5 6 7 8 9
                            A B C D E F G H J K
                            M N P Q R S T V W X Y Z);
sub _gen_rand_cfbase32 {
    my ($min_len, $max_len, $zero_prefix) = @_;
    my $len = int($min_len + rand()*($max_len - $min_len + 1));

    my @digits;
    for my $i (1..$len) {
        my $digit;
        if ($i == 1 && !$zero_prefix) {
            $digit = $cfbase32_digits_x0[rand @cfbase32_digits_x0];
        } else {
            $digit = $cfbase32_digits[rand @cfbase32_digits];
        }
        push @digits, $digit;
    }
    join "", @digits;
}

$SPEC{cfbase32_rand} = {
    v => 1.1,
    summary => "Generate one or more Crockford Base 32 numbers",
    args => {
        zero_prefix => {
            schema => 'bool*',
            default => 1,
            summary => 'When generating random number of certain length range, whether the first digit is allowed to be zero',
        },
        min_int => {
            schema => 'int*',
            tags => ['category:range'],
        },
        max_int => {
            schema => 'int*',
            tags => ['category:range'],
        },
        min_base32 => {
            schema => 'str*',
            tags => ['category:range'],
        },
        max_base32 => {
            schema => 'str*',
            tags => ['category:range'],
        },
        min_len => {
            summary => 'Specify how many minimum number of digits to generate',
            description => <<'MARKDOWN',

Note that the first digit can still be 0 unless zero_prefix is set to false.

MARKDOWN
            schema => ['int*', min=>1],
            tags => ['category:range'],
        },
        max_len => {
            summary => 'Specify how many maximum number of digits to generate',
            description => <<'MARKDOWN',

Note that the first digit can still be 0 unless zero_prefix is set to false.

MARKDOWN
            schema => ['int*', min=>1],
            tags => ['category:range'],
        },
        len => {
            summary => 'Specify how many number of digits to generate for a number',
            description => <<'MARKDOWN',

Note that the first digit can still be 0 unless zero_prefix is set to false.

MARKDOWN
            schema => ['int*', min=>1],
            tags => ['category:range'],
        },

        num => {
            summary => 'Specify how many numbers to generate',
            schema => 'uint*',
            default => 1,
            cmdline_aliases => {n=>{}},
            tags => ['category:quantity'],
        },

        unique => {
            schema => 'bool*',
            summary => 'Whether to avoid generating previously generated numbers',
        },
        prev_nums_file => {
            schema => 'filename*',
        },
    },
    args_rels => {
        'choose_all&' => [
            [qw/from_int to_int/],
            [qw/from_base32 to_base32/],
            [qw/from_digits to_digits/],
        ],
        req_one => [
            qw/min_int min_base32 min_len len/,
        ],
    },
    examples => [
        {
            summary => 'Generate 35 random numbers from 12 digits each, first digit(s) can be 0',
            argv => [qw/--len 12 -n35/],
            test => 0,
        },
        {
            summary => 'Generate 35 random numbers from 12 digits each, first digit(s) CANNOT be 0',
            argv => [qw/--len 12 -n35 --nozero-prefix/],
            test => 0,
        },
    ],
};
sub cfbase32_rand {
    require Encode::Base32::Crockford;

    my %args = @_;
    my ($gen, $from, $to, $fmt);
    if ($args{len}) {
        if ($args{len} >= 9) {
            $gen = sub { _gen_rand_cfbase32($args{len}, $args{len}, $args{zero_prefix}) };
        } else {
            $from = 32 ** ($args{len} - 1);
            $to = 32 ** ($args{len}) - 1;
        }
    } elsif (defined($args{min_len})) {
        if ($args{min_len} >= 9 || $args{max_len} >= 9) {
            $gen = sub { _gen_rand_cfbase32($args{min_len}, $args{max_len}, $args{zero_prefix}) };
        } else {
            $from = 32 ** int($args{min_len} - 1);
            $to   = 32 ** int($args{max_len}) - 1;
        }
    } elsif (defined($args{min_int})) {
        $from = int($args{min_int});
        $to   = int($args{max_int});
    } elsif (defined($args{min_base32})) {
        $from = Encode::Base32::Crockford::base32_decode($args{min_base32});
        $to   = Encode::Base32::Crockford::base32_decode($args{max_base32});
    } else {
        return [400, "Please specify range"];
    }
    log_trace "from: %s   to: %s", $from, $to;

    my @res;
    for my $i (1 .. $args{num}) {
        my $enc;
        if ($gen) {
            $enc = $gen->();
        } else {
            my $num = int(rand() * ($to - $from + 1) + $from);
            $enc = Encode::Base32::Crockford::base32_encode($num);
        }
        push @res, $enc;
    }

    [200, "OK", \@res];
}

1;
# ABSTRACT: Utilities related to Crockford's Base 32 encoding

=head1 DESCRIPTION

This distribution contains the following CLIs:

# INSERT_EXECS_LIST

Keywords: base32, base 32, crockford's base 32


=head1 SEE ALSO

L<https://www.crockford.com/base32.html>
