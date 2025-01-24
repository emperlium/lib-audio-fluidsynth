use strict;
use warnings;

use Test::More tests => 5;

use_ok( 'Nick::Audio::FluidSynth' );

my $buffer;
my $fluidsynth = Nick::Audio::FluidSynth -> new(
    'buffer_out'    => \$buffer,
    'sample_rate'   => 11025,
    'audio_bytes'   => 500,
    'gain'          => 1
);

ok( defined( $fluidsynth ), 'new()' );

my $sf_id = $fluidsynth -> load_soundfont(
    $ENV{'TEST_SOUNDFONT'} || '/usr/share/sounds/sf2/FluidR3_GM.sf2'
);

ok( $sf_id, 'load_soundfont()' );

my @presets = $fluidsynth -> get_presets( $sf_id );
ok( @presets > 0, 'get_presets()' );

$fluidsynth -> setting_int( 'synth.reverb.active', 0 );
$fluidsynth -> setting_int( 'synth.chorus.active', 0 );

$fluidsynth -> send_note( 9, 62, 127, 10 );
$fluidsynth -> process();
my $rms = 0;
for ( unpack 's*', $buffer ) {
    $rms += $_ ** 2;
}
ok( sqrt( $rms ) > 1000, 'Processed PCM' );
