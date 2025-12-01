use v5.30;
use warnings;
use Getopt::Std;

our $opt_d;
getopts('d');
my $pause = 1;
my $launchOptikey;

if ($opt_d) {
	$launchOptikey = 'start C:\Users\kevin\Optikey\OptiKey\src\JuliusSweetland.OptiKey.Pro\bin\Debug\OptikeyPro.exe';
} else {
	$launchOptikey = 'start "C:\Program Files (x86)\Optikey Pro\OptikeyPro.exe"';
}

system 'start "C:\Program Files\AutoHotkey\AutoHotkeyU32_UIA.exe" "C:\Users\kevin\My Files\Optikey Scripts\scripts\closeOpti.ahk"';
sleep($pause);
system 'start "C:\Program Files\AutoHotkey\AutoHotkeyU32_UIA.exe" "C:\Users\kevin\My Files\Optikey Scripts\scripts\Optikey.ahk"';
system $launchOptikey;

while(0) { #change to 1 to enable
	sleep(10);
	LaunchIfCrashed();
}

sub LaunchIfCrashed {
	$_ = `tasklist | grep -i optikeypro`;
	unless (/Optikey/) {
		say STDERR "Crash detected. Restarting...";
		system $launchOptikey;
	}
}











