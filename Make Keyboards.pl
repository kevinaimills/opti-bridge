use v5.30;
use warnings;
use Getopt::Std;

our $opt_s;
our $opt_d;
our $opt_m;
getopts('mds:');
chdir '..' if $opt_d;
my $outDir = 'C:\Users\kevin\AppData\Roaming\Optikey\OptiKey\Keyboards\\';
#my $outDir = '..\\test\\';

#print STDERR "d" if $opt_d;
#print STDERR "s" if $opt_s;
#sleep(1);

$_ = slurp('defaults.kdef');
my $grid = $1 if (/(<Grid>.*?<\/Grid>)/i) or die $!;
my $keygroup = $1 if (/(<Keygroup.*?\/>)/i);
my $close = $1 if (/(<DynamicKey.*?Close.*?<\/DynamicKey>)/is);
my $blank = $1 if (/(<DynamicKey>.*?<Label>\s<.*?<\/DynamicKey>)/is);

open(my $in, '<', 'shorthand.kdef') or die $!;
my %defs;
my %expand;
my %send;
my %meta;
while(<$in>) {
	$meta{$1} = $2 if (/^\s*\[(.*)\]\[(.*)\]/);
#	$meta{quotemeta($1)} = $2 if (/^\s*\[(.*)\]\[(.*)\]/);
	$defs{$1} = $2 if (/^\s*([a-z]+)=(\S+)/);
	$expand{$1} = $2 if (/^\s*([a-z]+)\\(\S+)/);
	$send{$1} = $2 if (/^\s*(.)-([a-zA-Z]+)/);		
}
my $sends;
$sends .= quotemeta($_) while (each %send);

chdir 'ktemp' or die $!;

my $headBot = slurp('DefHeaderBot.xml');
my $headMain = slurp('DefHeaderMain.xml');
my $foot = slurp('DefFooter.xml');

# KMAINs

my @kmain = glob '*.kmain';

foreach (@kmain) {
	open($in, '<', $_) or die $!;
	s/kmain/xml/;
	open(my $out, '>', $outDir . $_) or die $!;
	s/xml//;
	my $fileName = $_;
	select $out;
	my $con = "";
	$con .= $headMain;

	while(<$in>) {
		$con .= doLines($_);
	}

	$con =~ s/<Cols>3<\/Cols>/<Cols>48<\/Cols>/g if $fileName =~ m/KevinBottomRuler/;
	$con =~ s/CompletionTimes="(\d+)"/CompletionTimes="3000"/ if $fileName =~ m/KevinBottomRuler/;
	$con =~ s/<ChangeKeyboard( Copy="No")?>/<ChangeKeyboard BackReturnsHere=\"False\">/g;
	$con =~ s/ReturnKeyboard/ChangeKeyboard/g;
	$con =~ s/<DynamicKey.*DeleteIfM[\D\d]*?\/DynamicKey>//g if $opt_m; # [\D\d] instead of /s flag for including \n
	$con =~ s/<DynamicKey.*DeleteUnlessM[\D\d]*?\/DynamicKey>//g unless $opt_m; # [\D\d] instead of /s flag for including \n
	print $con;

}

# KBOTs

my @kbot = glob '*.kbot';
my $fname;
my $kname;
my $rname;
my $body;
my $cols;
my $rows;
my $ktime;
my $onClose = 0;

foreach (@kbot) {
	my @keys;
	$body = '';
	$fname = $_;
	$kname = s/\.kbot//r;
	$rname = s/Kevin([A-Z][a-z]*).*/Kevin$1/r;
	$ktime = 0;
	$onClose = 0;
	open($in, '<', $fname) or die $!;
	open(my $out, '>', $outDir . $kname . '.xml') or die $!;
	select $out;

	$body .= doLines($_) while(<$in>);
	$body =~ s/<!--.*?-->//gs;
	
	my $grid = $body =~ s/(<Grid>.*?<\/Grid>)//i ? $1 : doGrid(); 
	$cols = $1 if ($grid =~ /<Cols>(\d+)<\/Cols>/i);
	$rows = $1 if ($grid =~ /<Rows>(\d+)<\/Rows>/i);
	my $keygroup = $body =~ s/(<Keygroup.*?\/>)//i ? $1 : doKeygroup();
	my $close = $body =~ s/(<DynamicKey.*?Close.*?<\/DynamicKey>)//i ? $1 : doClose();
	
	push @keys, $1 while ($body =~ s/(<DynamicKey.*?<\/DynamicKey>)//s);
	push @keys, $close;
	@keys = doKeys(@keys);
	
	print $headBot;
	say "\t" . $grid;
	say "\t" . $keygroup;
	say "\t<Content>";
	say foreach @keys;
	say $foot;
}

sub doLines {
	return '' if (/^\s*#/ || /\A\s*\Z/);
	s/^\s*//;
	$_ = expandShort($_[0]);
	return $_;
}

sub doMulti {
	my @lines = split /\n/, $_[0];
	$_ = doLines($_) foreach (@lines);
	join "\n", @lines;
}

sub doKeys {
#	for (my $i = @_; $i < 10; $i++) {
#		splice @_, @_ - 1, 0, ($blank);
#	}
	
	foreach (@_) {
		unless ($_ =~ /<Symbol>/) {
			$_ =~ s/(<DynamicKey)/$1 SharedSizeGroup=\"text\"/;
		}
		
		if ($_ !~ /<Symbol>/ && $_ !~ /<Label>/) {
			my $label;
			if ($_ =~ /<Text>(.*?)<\/Text>/) {
				$label = $1;
			} elsif ($_ =~ /<Action>(.*?)<\/Action>/) {
				$label = $1;
			} elsif ($_ =~ /<(Change|Return)Keyboard.*?>(.*?)<\/ChangeKeyboard>/) {
				$label = $2;
				$label =~ s/.*([A-Z][a-z]*)$/$1/;
			}
			$_ =~ s/(<DynamicKey.*?>)/$1\n<Label>$label<\/Label>/ if $label;
		}
		s/CompletionTimes="\d*"// if $opt_s;
		s/(<\/DynamicKey.*?>)/expandShort("." . $onClose) . "\n" . $1/e if ($onClose && (/ChangeKeyboard/ || /BackFromKeyboard/) && $_ !~ /NotAClose/);
		s/<DynamicKey/'<DynamicKey CompletionTimes="' . $ktime . ', ' . ($ktime+250) . '"'/e unless ($ktime == 0 || /ChangeKeyboard/ || /BackFromKeyboard/ || /CompletionTimes/);# || $keygroup !~ /CanOverride="True"/);
#		s/<DynamicKey CompletionTimes=".*"/'<DynamicKey CompletionTimes="' . ($ktime+250) . '"'/e if ($fname =~ /BottomArrows/);
		s/<DynamicKey/<DynamicKey Height=\"3\"/g unless (/<Label>Close/i || /Height=/);
		s/<ChangeKeyboard( Copy="No")?>/<ChangeKeyboard BackReturnsHere=\"False\">/g;
		s/ReturnKeyboard/ChangeKeyboard/g;

		my $moveCloseToTop = "";
		my $moveCloseToTop = $1 if s/(<ChangeKeyboard.*\/ChangeKeyboard>)//;
		s/<DynamicKey(.*?)>/<DynamicKey$1>$moveCloseToTop/;

		my $movePauseToBottom = "";
		my $movePauseToBottom = $1 if s/(<Action>Sleep<\/Action>[\s\n]*<Wait>\d+<\/Wait>[\s\n]*<Action>Sleep<\/Action>)//m;
		s/<\/DynamicKey>/$movePauseToBottom<\/DynamicKey>/;

		s/\R\s*\R/\n/gm;
		s/^/\t\t/gm;
		s/\n\t(?!.*Dyn)/\n\t\t/g;
	}
	return (@_);
}

sub doGrid {
	my $grid = $grid;
	return $grid;
}

sub doKeygroup {
	my $keygroup = $keygroup;
	my $ctime = $1 if $keygroup =~ /Times=\"(\d+)/;
	$ctime = 350 if $kname =~ /(Keyboard|Perl)/;
	$ctime *= 12 if $kname =~ /(Trans|Tags|Phrases)/;
	$ctime = $opt_s if ($opt_s); # && $fname !~ /BottomMain/); 
	$keygroup =~ s/(Times=)\"[\d\s,]*\"/$1\"$ctime, 250\"/;
	if ($body =~ s/Opacity([\d\.]*)//) {
		my $opacity = $1;
		my $opacityDown = $1 + 0.2;
		$keygroup =~ s/Opacity=\"[\d\.]*\"/Opacity=\"$opacity\" KeyDownOpacity=\"$opacityDown\"/;
	}
	$ktime = $1 if $keygroup =~ /CompletionTimes=\"(\d+)/;
	return $keygroup;
}

sub doClose {
	my $close = $close;
	return "" if $body =~ s/close=donotclose//i;
	$close =~ s/(.*Width=\")([0-9]*)(\".*)/$1$cols$3/g;
	if ($body =~ s/close=(\S*)//) {

		my $closeLoc = $1;

		if ($1 eq "BackFromKeyboard") {
			$close =~ s/<ChangeKeyboard[\s"=A-Za-z]*>.*<\/ChangeKeyboard>/<Action>BackFromKeyboard<\/Action>/;
		} else {
			$close =~ s/(<ChangeKeyboard[\s"=A-Za-z]*>).*<\/ChangeKeyboard>/$1$closeLoc<\/ChangeKeyboard>/;
		}
	} else {
		$close =~ s/(<ChangeKeyboard[\s"=A-Za-z]*>)[A-Za-z]*<\/ChangeKeyboard>/$1$rname<\/ChangeKeyboard>/;
#		$close =~ s/(<ChangeKeyboard[\s"=A-Za-z]*>)[A-Za-z]*<\/ChangeKeyboard>/\1KevinBottom<\/ChangeKeyboard>/ if $fname =~ /Qwerty/;
	}
#	$close =~ s/(<DynamicKey.*?>)/$1\n .$onClose/ if $onClose;
	$close = doMulti($close);
	my $height = 2/11 * $rows;
	my $row = $rows - $height;
	$close =~ s/<DynamicKey/<DynamicKey Row="$row" Height="$height"/;
	if ($opt_s) {
		my $ktime = $opt_s;
		$close =~ s/(Times=)\"[\d\s,]*\"/$1\"$ktime\"/;
	} 
	return $close;
}

sub expandShort {

	$_ = $_[0];
	return '' if (/^\s*#/ || /\A\s*\Z/);
	
	if (/^(\s*)(\.?)([a-zA-Z]=|s-|\[[a-zA-Z]\])/) {
		s/(?<!=)\'(?!(\s+|$))/\&\#39;/;
		s/\"/\&\#34;/;
		s/\&/\&\#38;/;
		s/</\&\#60;/;
		s/>/\&\#62;/;
		my $closes;
		if (/c=/) {
			$closes = 1;
			s/c=0//;
		}
		while ( (my $k, my $v) = each %send ) {
			$k = quotemeta($k);
			s/(s-[$sends]*)$k([$sends]*)([a-zA-Z0-9]*)/d=$v $1$2$3 u=$v/g;
		}
		s/s-([a-zA-Z0-9]*)/d=$1 u=$1/g;

		while ( (my $k, my $v) = each %expand ) {
			s/(?<!\\)(\\)$k/$v/g;
		}
		s/(?<!\\)\\n/$kname/g;
		s/\\\\/\\/g;

		while ( (my $k, my $v) = each %defs ) {
			s/$k=\'(.*?)\'\s?/<$v>$1<\/$v>\n/g;
			s/$k=(\S+)\s?/<$v>$1<\/$v>\n/g;
		}
		
		if (/^(\s*)\./) {
			s/^(\s*)\.\s*\R*//;
		} else {
			$_ = "<ChangeKeyboard>$rname<\/ChangeKeyboard>\n" . $_ unless $closes;
			$_ = "<DynamicKey>\n" . $_;
			$_ .= "</DynamicKey>";
		}
	} elsif (/^(\s*)(\\|copy)/) {
		while ( (my $k, my $v) = each %expand ) {
			s/(\\)$k/$v/g;
		}
		s/\\n/$kname/g;
	}
	unless ($_[1]) {
		while ( (my $k, my $v) = each %meta ) {
			$_ = expandMulti($_, 1) if s/$k/$v/;
		}
	}
	
	if (s/copy\[([A-Za-z]*)\]\[(.*)\]\[(.*)\]//) {
		my $in;
		open($in, '<', $1 . '.kbot') or open($in, '<', $1 . '.kmain') or die $!;
		my $sub = $2;
		my $to = $3;
		my @subs = split /\s&&\s/, $sub;
		my @tos = split /\s&&\s/, $to;
		my $line;
		while(<$in>) {
			next if /Copy="No"/;
			for (my $i = 0; $i < @subs; $i++) {
				my $sub = $subs[$i];
				my $to = $tos[$i];
				s/$sub/$to/ig;
			}
			$line .= $_;
		}
		$_ = expandMulti($line);
	}

	if (s/onClose\[(.*)\]//) {
		$onClose = $1;
	}

	s/\R\s*\R/\n/mg;
	return $_;
}

sub expandMulti {
	my @lines = split /\n/, $_[0];
	$_ = expandShort($_, $_[1]) foreach (@lines);
	join "\n", @lines;
}

sub slurp {
	open(my $in, '<', $_[0]) or die $!;	
	my $str;
	while (<$in>) {
		$str .= $_ unless (/^\s*#/ || /\A\s*\Z/);
	}
	return $str;
}

sub foo {
	say STDERR $_[0];
}
