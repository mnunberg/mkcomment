#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Text::Wrap;
my $width = 80;
my $style = "pxx";
my $hpad = 3;
my $wpad = 3;
my $txt = "This is foo";

my $help = <<EOM;
USAGE: $0 [--width=80 --hpad=3 --wpad=3 --style=pxx] <message>
	--width: wrap at width
	--hpad: provide HPAD lines above and below header
	--wpad: provide comment char WPAD times on the beginning and end of line
	--style: comment style, pxx, cpp, or c89
EOM

if (grep $_ =~ /^-h|--help$/, @ARGV) {
	print STDERR $help;
	exit(1);
}
GetOptions(
	"width=i" => \$width,
	"style=s" => \$style,
	"hpad=i" => \$hpad,
	"wpad=i" => \$wpad,
);

my $COMMENT_CHAR;
if ($style =~ /pxx/i) {
	$COMMENT_CHAR = '#';
} elsif ($style =~ /c89/i) {
    $COMMENT_CHAR = '*';
} elsif ($style =~ /cpp/i) {
	$COMMENT_CHAR='/';
	if ($wpad < 2) {
		$wpad = 2;
	}
}

my $m_width = $width;
$m_width -= $wpad * 2; #Remove for padding on each side..
$m_width -= 2; #for space padding

$Text::Wrap::columns = $m_width;

my $message = pop(@ARGV);
if ($message && $message eq '-' || !$message) {
	$message = join("", <>);
}
$message = wrap("", "", $message);
my @lines = map { 
		my $l = $_;
		$l .= " " x ($m_width - length($l));
		$l = sprintf("%s %s %s", $COMMENT_CHAR x $wpad, $l, $COMMENT_CHAR x $wpad);
		$l;
	}
	split(/\n/, $message);

my $hdrftr = ($COMMENT_CHAR x $width);
foreach my $i (1..$hpad) {
	push @lines, $hdrftr;
	unshift @lines, $hdrftr;
}

if ($style =~ /c89/i) {
    substr($lines[0], 0, 1) = '/';
    substr($lines[-1], -1, 1) = '/';
    foreach my $line (@lines[1..$#lines]) {
        substr($line, 0, 1) = ' ';
    }
    foreach my $line (@lines[0..$#lines-1]) {
        substr($line, -1, 1) = '';
    }
}

$message = join("\n", @lines);
print $message . "\n";
