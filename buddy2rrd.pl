#!/usr/bin/perl
#
# Script is run by MaxBuddy to extract the measured temperatures in all rooms
# and put them into an rrd database for graph processing.
#
# v0.1 by fl0
#

use RRDs;
use DateTime;
use Time::Piece;
use POSIX;

# debuglevel: 1->output to stderr; 2->output to file buddy2rrd.debug
my $debuglevel = 0;

# variables needed for reading the MaxBuddy export file
my $buddyexportfile = "./buddyexport.csv";
my @line;

##############
# now comes the calculating part
##############


# reading values from the MaxBuddy export file
printf("Opening file $buddyexportfile...\n") if ($debuglevel == 1);
open(my $fh, "<", $buddyexportfile)
   or die "cannot open input file: $!";

my $last_line;
while(<$fh>) {
      $last_line = $_ if eof;
}
@line = split(/;/, $last_line);
close($fh);

printf("Deleting file $buddyexportfile...\n") if ($debuglevel == 1);
unlink($buddyexportfile);

my $livingroom_temperature = $line[19];
my $livingroom_target_temperature = $line[16];
my $livingroom_mode = 0;
if ($line[17] eq "Auto" && ($line[18] eq "Normal" || $line[18] eq "Comfort")) {
   $livingroom_mode = 1;
}
if (($line[17] eq "Auto" || $line[17] eq "Permanently") && $line[18] eq "Eco") {
   $livingroom_mode = 2;
}
if ($line[17] eq "Permanently" && $line[18] eq "Normal") {
   $livingroom_mode = 3;
}
my $livingroom_window = 0;
my $livingroom_window_k = 0;
my $livingroom_window_t = 0;
my $livingroom_window_f= 0;
if ($line[60] eq "true") {
   $livingroom_window = 1;
   $livingroom_window_k = 1;
}
if ($line[69] eq "true") {
   $livingroom_window = 1;
   $livingroom_window_t = 1;
}
if ($line[78] eq "true") {
   $livingroom_window = 1;
   $livingroom_window_f = 1;
}
my $livingroom_valve = ceil(($line[40]+$line[51])/2);
my $nursery_temperature = $line[84];
my $nursery_target_temperature = $line[81];
my $nursery_mode = 0;
if ($line[82] eq "Auto" && ($line[83] eq "Normal" || $line[83] eq "Comfort")) {
   $nursery_mode = 1;
}
if (($line[82] eq "Auto" || $line[82] eq "Permanently") && $line[83] eq "Eco") {
   $nursery_mode = 2;
}
if ($line[82] eq "Permanently" && $line[83] eq "Normal") {
   $livingroom_mode = 3;
}
my $nursery_window = 0;
if ($line[114] eq "true") {
   $nursery_window = 1;
}
my $nursery_valve = $line[105];
my $sleepingroom_temperature = $line[120];
my $sleepingroom_target_temperature = $line[117];
my $sleepingroom_mode = 0;
if ($line[118] eq "Auto" && ($line[119] eq "Normal" || $line[119] eq "Comfort")) {
   $sleepingroom_mode = 1;
}
if (($line[118] eq "Auto" || $line[118] eq "Permanently") && $line[119] eq "Eco") {
   $sleepingroom_mode = 2;
}
if ($line[118] eq "Permanently" && $line[119] eq "Normal") {
   $sleepingroom_mode = 3;
}
my $sleepingroom_window = 0;
my $sleepingroom_window_v = 0;
my $sleepingroom_window_h = 0;
if ($line[150] eq "true") {
   $sleepingroom_window = 1;
   $sleepingroom_window_v = 1;
}
if ($line[159] eq "true") {
   $sleepingroom_window = 1;
   $sleepingroom_window_h = 1;
}
my $sleepingroom_valve = $line[141];
my $office_temperature = $line[165];
my $office_target_temperature = $line[162];
my $office_mode = 0;
if ($line[163] eq "Auto" && ($line[164] eq "Normal" || $line[164] eq "Comfort")) {
   $office_mode = 1;
}
if (($line[163] eq "Auto" || $line[163] eq "Permanently") && $line[164] eq "Eco") {
   $office_mode = 2;
}
if ($line[163] eq "Permanently" && $line[164] eq "Normal") {
   $office_mode = 3;
}
my $office_window = 0;
if ($line[195] eq "true") {
   $office_window = 1;
}
my $office_valve = $line[186];
my $bathroom_temperature = $line[201];
my $bathroom_target_temperature = $line[198];
my $bathroom_mode = 0;
if ($line[199] eq "Auto" && ($line[200] eq "Normal" || $line[200] eq "Comfort")) {
   $bathroom_mode = 1;
}
if (($line[199] eq "Auto" || $line[199] eq "Permanently") && $line[200] eq "Eco") {
   $bathroom_mode = 2;
}
if ($line[199] eq "Permanently" && $line[200] eq "Normal") {
   $bathroom_mode = 3;
}
my $bathroom_window = 0;
if ($line[231] eq "true") {
   $bathroom_window = 1;
}
my $bathroom_valve = $line[222];
my $lavatory_temperature = $line[237];
my $lavatory_target_temperature = $line[234];
my $lavatory_mode = 0;
if ($line[235] eq "Auto" && ($line[236] eq "Normal" || $line[236] eq "Comfort")) {
   $lavatory_mode = 1;
}
if (($line[235] eq "Auto" || $line[235] eq "Permanently") && $line[236] eq "Eco") {
   $lavatory_mode = 2;
}
if ($line[235] eq "Permanently" && $line[236] eq "Normal") {
   $lavatory_mode = 3;
}
my $lavatory_window = 0;
if ($line[267] eq "true") {
   $lavatory_window = 1;
}
my $lavatory_valve = $line[258];

# now update the rrd database with the current values
RRDs::update ("weather.rrd","N:$livingroom_temperature:$livingroom_target_temperature:$livingroom_mode:$livingroom_window:$livingroom_window_k:$livingroom_window_t:$livingroom_window_f:$livingroom_valve:$nursery_temperature:$nursery_target_temperature:$nursery_mode:$nursery_window:$nursery_valve:$sleepingroom_temperature:$sleepingroom_target_temperature:$sleepingroom_mode:$sleepingroom_window:$sleepingroom_window_v:$sleepingroom_window_h:$sleepingroom_valve:$office_temperature:$office_target_temperature:$office_mode:$office_window:$office_valve:$bathroom_temperature:$bathroom_target_temperature:$bathroom_mode:$bathroom_window:$bathroom_valve:$lavatory_temperature:$lavatory_target_temperature:$lavatory_mode:$lavatory_window:$lavatory_valve");

##############
# debug outputs
##############

if ($debuglevel == 1) {
   printf ("temperature living room: $livingroom_temperature\n");
   printf ("target temperature living room: $livingroom_target_temperature\n");
   printf ("mode living room: $livingroom_mode\n");
   printf ("window living room: $livingroom_window\n");
   printf ("living room valve position: $livingroom_valve\n");
   printf ("temperature nursery: $nursery_temperature\n");
   printf ("target temperature nursery: $nursery_target_temperature\n");
   printf ("mode nursery: $nursery_mode\n");
   printf ("window nursery: $nursery_window\n");
   printf ("nursery valve position: $nursery_valve\n");
   printf ("temperature bedroom: $sleepingroom_temperature\n");
   printf ("target temperature bedroom: $sleepingroom_target_temperature\n");
   printf ("mode bedroom: $sleepingroom_mode\n");
   printf ("window bedroom: $sleepingroom_window\n");
   printf ("bedroom valve position: $sleepingroom_valve\n");
   printf ("temperature office: $office_temperature\n");
   printf ("target temperature office: $office_target_temperature\n");
   printf ("mode office: $office_mode\n");
   printf ("window office: $office_window\n");
   printf ("office valve position: $office_valve\n");
   printf ("temperature bathroom: $bathroom_temperature\n");
   printf ("target temperature bathroom: $bathroom_target_temperature\n");
   printf ("mode bathroom: $bathroom_mode\n");
   printf ("window bathroom: $bathroom_window\n");
   printf ("bathroom valve position: $bathroom_valve\n");
   printf ("temperature lavatory: $lavatory_temperature\n");
   printf ("target temperature lavatory: $lavatory_target_temperature\n");
   printf ("mode lavatory: $lavatory_mode\n");
   printf ("window lavatory: $lavatory_window\n");
   printf ("lavatory valve position: $lavatory_valve\n");
}

if ($debuglevel == 2) {
   open ($fh, ">>", "buddy2rrd.debug") or die "cannot open output file: $!";
   printf $fh ("temperature living room: $livingroom_temperature\n");
   printf $fh ("target temperature living room: $livingroom_target_temperature\n");
   printf $fh ("mode living room: $livingroom_mode\n");
   printf $fh ("window living room: $livingroom_window\n");
   printf $fh ("living room valve position: $livingroom_valve\n");
   printf $fh ("temperature nursery: $nursery_temperature\n");
   printf $fh ("target temperature nursery: $nursery_target_temperature\n");
   printf $fh ("mode nursery: $nursery_mode\n");
   printf $fh ("window nursery: $nursery_window\n");
   printf $fh ("nursery valve position: $nursery_valve\n");
   printf $fh ("temperature bedroom: $sleepingroom_temperature\n");
   printf $fh ("target temperature bedroom: $sleepingroom_target_temperature\n");
   printf $fh ("mode bedroom: $sleepingroom_mode\n");
   printf $fh ("window bedroom: $sleepingroom_window\n");
   printf $fh ("bedroom valve position: $sleepingroom_valve\n");
   printf $fh ("temperature office: $office_temperature\n");
   printf $fh ("target temperature office: $office_target_temperature\n");
   printf $fh ("mode office: $office_mode\n");
   printf $fh ("window office: $office_window\n");
   printf $fh ("office valve position: $office_valve\n");
   printf $fh ("temperature bathroom: $bathroom_temperature\n");
   printf $fh ("target temperature bathroom: $bathroom_target_temperature\n");
   printf $fh ("mode bathroom: $bathroom_mode\n");
   printf $fh ("window bathroom: $bathroom_window\n");
   printf $fh ("bathroom valve position: $bathroom_valve\n");
   printf $fh ("temperature lavatory: $lavatory_temperature\n");
   printf $fh ("target temperature lavatory: $lavatory_target_temperature\n");
   printf $fh ("mode lavatory: $lavatory_mode\n");
   printf $fh ("window lavatory: $lavatory_window\n");
   printf $fh ("lavatory valve position: $lavatory_valve\n");
   printf $fh ("----------------------------------------------------\n");
}

exit(0);
