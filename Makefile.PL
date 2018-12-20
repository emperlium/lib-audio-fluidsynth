use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Nick::Audio::FluidSynth',
    VERSION_FROM        => 'lib/Nick/Audio/FluidSynth.pm',
    AUTHOR              => 'Nick Peskett',
    LIBS                => [ '-lfluidsynth' ],
    DEFINE              => '-DINCLUDE_FLUIDSYNTH_H',
    TEST_REQUIRES       => {
        'Test::More' => 0
    }
);
