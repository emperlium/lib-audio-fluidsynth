#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <fluidsynth.h>

struct nickaudiofluidsynth {
    fluid_settings_t *settings;
    fluid_synth_t *synth;
    fluid_sequencer_t *sequencer;
    fluid_audio_driver_t *audio_driver;
    short synth_seq_id;
    char *pcm_out;
    SV *scalar_out;
    unsigned int bytes;
    unsigned int samples;
    bool has_audio_driver;
};

typedef struct nickaudiofluidsynth NICKAUDIOFLUIDSYNTH;

MODULE = Nick::Audio::FluidSynth  PACKAGE = Nick::Audio::FluidSynth

static NICKAUDIOFLUIDSYNTH *
NICKAUDIOFLUIDSYNTH::new_xs( scalar_out, sample_rate, bytes, gain )
        SV *scalar_out;
        float sample_rate;
        unsigned int bytes;
        float gain;
    CODE:
        Newxz( RETVAL, 1, NICKAUDIOFLUIDSYNTH );
        RETVAL -> bytes = bytes;
        RETVAL -> samples = bytes / 4;
        RETVAL -> settings = new_fluid_settings();
        fluid_settings_setnum( RETVAL -> settings, "synth.sample-rate", sample_rate );
        RETVAL -> synth = new_fluid_synth( RETVAL -> settings );
        fluid_synth_set_gain( RETVAL -> synth, gain );
        RETVAL -> sequencer = new_fluid_sequencer2( 0 );
        RETVAL -> synth_seq_id = fluid_sequencer_register_fluidsynth(
            RETVAL -> sequencer, RETVAL -> synth
        );
        if ( SvROK( scalar_out ) ) {
            scalar_out = SvRV( scalar_out );
        }
        RETVAL -> scalar_out = SvREFCNT_inc( scalar_out );
        Newx( RETVAL -> pcm_out, bytes + 1, char );
        RETVAL -> has_audio_driver = false;
    OUTPUT:
        RETVAL

void
NICKAUDIOFLUIDSYNTH::DESTROY()
    CODE:
        SvREFCNT_dec( THIS -> scalar_out );
        Safefree( THIS -> pcm_out );
        if ( THIS -> has_audio_driver ) {
            delete_fluid_audio_driver( THIS -> audio_driver );
        }
        delete_fluid_sequencer( THIS -> sequencer );
        delete_fluid_synth( THIS -> synth );
        delete_fluid_settings( THIS -> settings );
        Safefree( THIS );

int
NICKAUDIOFLUIDSYNTH::load_soundfont( soundfont, reset_presets = 1 )
        const char *soundfont;
        int reset_presets;
    CODE:
        RETVAL = fluid_synth_sfload(
            THIS -> synth, soundfont, reset_presets
        );
        if ( RETVAL == FLUID_FAILED ) {
            croak( "Unable to load soundfont: %s", soundfont );
        }
    OUTPUT:
        RETVAL

void
NICKAUDIOFLUIDSYNTH::setting_string( key, value )
        const char *key;
        const char *value;
    CODE:
        if (
            fluid_settings_setstr(
                THIS -> settings, key, value
            ) == FLUID_FAILED
        ) {
            croak( "Unable to set setting %s with %s", key, value );
        }

void
NICKAUDIOFLUIDSYNTH::setting_int( key, value )
        const char *key;
        int value;
    CODE:
        if (
            fluid_settings_setint(
                THIS -> settings, key, value
            ) == FLUID_FAILED
        ) {
            croak( "Unable to set setting %s with %d", key, value );
        }

void
NICKAUDIOFLUIDSYNTH::setting_num( key, value )
        const char *key;
        double value;
    CODE:
        if (
            fluid_settings_setnum(
                THIS -> settings, key, value
            ) == FLUID_FAILED
        ) {
            croak( "Unable to set setting %s with %f", key, value );
        }

void
NICKAUDIOFLUIDSYNTH::add_audio_driver()
    CODE:
        THIS -> audio_driver = new_fluid_audio_driver(
            THIS -> settings, THIS -> synth
        );
        THIS -> has_audio_driver = true;

void
NICKAUDIOFLUIDSYNTH::del_audio_driver()
    CODE:
        if ( THIS -> has_audio_driver ) {
            delete_fluid_audio_driver( THIS -> audio_driver );
            THIS -> has_audio_driver = false;
        }

SV *
NICKAUDIOFLUIDSYNTH::get_buffer_out_ref()
    CODE:
        RETVAL = newRV_inc( THIS -> scalar_out );
    OUTPUT:
        RETVAL

void
NICKAUDIOFLUIDSYNTH::process()
    CODE:
        if (
            fluid_synth_write_s16(
                THIS -> synth,
                THIS -> samples,
                THIS -> pcm_out, 0, 2,
                THIS -> pcm_out, 1, 2
            ) == FLUID_FAILED
        ) {
            croak( "Unable to build PCM data" );
        }
        sv_setpvn(
            THIS -> scalar_out,
            THIS -> pcm_out,
            THIS -> bytes
        );

void
NICKAUDIOFLUIDSYNTH::set_preset( channel, sf_id, bank, preset )
        int channel;
        int sf_id;
        int bank;
        int preset;
    CODE:
        if (
            fluid_synth_program_select(
                THIS -> synth, channel, sf_id, bank, preset
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set channel %d, bank %d to preset %d",
                channel, bank, preset
            );
        }

void
NICKAUDIOFLUIDSYNTH::set_program( channel, program )
        int channel;
        int program;
    CODE:
        if (
            fluid_synth_program_change(
                THIS -> synth, channel, program
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set channel %d, program %d",
                channel, program
            );
        }

void
NICKAUDIOFLUIDSYNTH::set_channel_type( channel, type )
        int channel;
        int type;
    CODE:
        if (
            fluid_synth_set_channel_type(
                THIS -> synth, channel, type
            ) == FLUID_FAILED
        ) {
            croak( "Unable to set channel %d to %d", channel, type );
        }

void
NICKAUDIOFLUIDSYNTH::set_controller( channel, number, value )
        int channel;
        int number;
        int value;
    CODE:
        if (
            fluid_synth_cc(
                THIS -> synth, channel, number, value
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set controller event on channel %d, number %d to value %d",
                channel, number, value
            );
        }

void
NICKAUDIOFLUIDSYNTH::set_pitch_bend( channel, bend )
        int channel;
        int bend;
    CODE:
        if (
            fluid_synth_pitch_bend(
                THIS -> synth, channel, bend
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set channel %d to pitch bend %d",
                channel, bend
            );
        }

void
NICKAUDIOFLUIDSYNTH::send_note( channel, key, velocity, duration )
        int channel;
        short key;
        short velocity;
        int duration;
    INIT:
        unsigned int date;
        fluid_event_t *evt;
    CODE:
        date = fluid_sequencer_get_tick( THIS -> sequencer );
        evt = new_fluid_event();
        fluid_event_set_source( evt, -1 );
        fluid_event_set_dest( evt, THIS -> synth_seq_id );

        fluid_event_noteon( evt, channel, key, velocity );
        if (
            fluid_sequencer_send_at(
                THIS -> sequencer, evt, date, 1
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set channel %d note on %d,%d", channel, key, velocity
            );
        }

        fluid_event_noteoff( evt, channel, key );
        if (
            fluid_sequencer_send_at(
                THIS -> sequencer, evt, date + duration, 1
            ) == FLUID_FAILED
        ) {
            croak(
                "Unable to set channel %d note off %d", channel, key
            );
        }

        delete_fluid_event( evt );

int
NICKAUDIOFLUIDSYNTH::active_voices()
    CODE:
        RETVAL = fluid_synth_get_active_voice_count( THIS -> synth );
    OUTPUT:
        RETVAL

void
NICKAUDIOFLUIDSYNTH::system_reset()
    CODE:
        if (
            fluid_synth_system_reset( THIS -> synth ) == FLUID_FAILED
        ) {
            croak( "Unable to reset system" );
        }

AV *
NICKAUDIOFLUIDSYNTH::get_presets_xs( sf_id )
        int sf_id;
    CODE:
        fluid_sfont_t* sf = fluid_synth_get_sfont_by_id(
            THIS -> synth, sf_id
        );
        if ( sf == NULL ) {
            croak( "Unable to get soundfont id: %d", sf_id );
        }
        RETVAL = newAV();
        sv_2mortal( (SV*)RETVAL );
        fluid_preset_t* preset;
        fluid_sfont_iteration_start( sf );
        for ( ;; ) {
            preset = fluid_sfont_iteration_next( sf );
            if ( preset == NULL ) {
                break;
            }
            HV * hash = (HV *)sv_2mortal( (SV *)newHV() );
            hv_store( hash,
                "bank", 4,
                newSViv( fluid_preset_get_banknum( preset ) ),
            0 );
            hv_store( hash,
                "preset", 6,
                newSViv( fluid_preset_get_num( preset ) ),
            0 );
            hv_store( hash,
                "name", 4,
                newSVpv( fluid_preset_get_name( preset ), 0 ),
            0 );
            av_push( RETVAL, newRV( (SV *)hash ) );
        }
    OUTPUT:
        RETVAL
