(
var patch_dir = thisProcess.nowExecutingPath.dirname;
var bundled_desc_path = patch_dir +/+ "behringer-x-touch-mini.desc.scd";
var expected_log_revision = "2026-08-08-log-palette-v2";
var expected_device_revision = "2026-09-09-device-r8.1";
var expected_processes_revision = "2026-09-10-relative3-r8.3";
var expected_layer_b_revision = "2026-09-10-relative3-r8.3";
var expected_mc_revision = "2026-09-10-orbit-process-leds-r8.4";
var expected_ktlloop_revision = "2026-08-31-auto-capture-r8";
var expected_hud_revision = "2026-09-10-mc-orbit-focus-r8.4";

// Todos os módulos compartilham as mesmas variáveis de ambiente, mesmo quando
// o loader é avaliado dentro de uma ProxySpace.
if (currentEnvironment.class == ProxySpace) { topEnvironment.push };
q.xtouch = q.xtouch ? ();
q.xtouch.patch_revision = "2026-09-10-r8.4";
q.xtouch.patch_dir = patch_dir;
q.xtouch.desc_path = bundled_desc_path;

// A extensão MC da descrição agora faz parte do próprio pacote. Registramos
// esta pasta no Modality antes de MKtl.find, para que a descrição incluída
// prevaleça sobre a versão padrão, sem sobrescrever arquivos do Quark.
if (File.exists(bundled_desc_path).not) {
    Error(
        "behringer-x-touch-mini.desc.scd ausente no pacote r8.4."
    ).throw;
};
MKtlDesc.addFolder(patch_dir, "");
MKtlDesc.loadDescs("behringer-x-touch-mini");

// Configuração pública. Valores definidos pelo usuário antes de carregar o
// patch são preservados; os demais recebem defaults seguros.
~xtouch_config = ~xtouch_config ? ();
~xtouch_config[\loopCount] = ~xtouch_config[\loopCount] ? 4;
~xtouch_config[\looped] = ~xtouch_config[\looped] ? true;
~xtouch_config[\palindrome] = ~xtouch_config[\palindrome] ? true;
~xtouch_config[\clearHoldSeconds] =
~xtouch_config[\clearHoldSeconds] ? 1.2;
~xtouch_config[\timelineCycleBeats] =
~xtouch_config[\timelineCycleBeats] ? 4;
~xtouch_config[\mcWetScale] = ~xtouch_config[\mcWetScale] ? 2.0;
~xtouch_config[\encoderLagTime] =
~xtouch_config[\encoderLagTime] ? 0.2;
~xtouch_config[\encoderRelativeScale] =
~xtouch_config[\encoderRelativeScale] ? 0.5;
~xtouch_config[\showHud] = ~xtouch_config[\showHud] ? true;
~xtouch_config[\hudAlwaysOnTop] =
~xtouch_config[\hudAlwaysOnTop] ? true;
q.xtouch.config = ~xtouch_config;

// Remove confirmações deixadas por uma tentativa anterior. Cada módulo desta
// carga terá de recriar sua própria marca antes de o loader prosseguir.
~xtouch_loaded_modules = List.new;
q.xtouch.loaded_modules = ~xtouch_loaded_modules;
~xtouch_log_revision = nil;
~xtouch_device_revision = nil;
~xtouch_processes_revision = nil;
~xtouch_layer_b_revision = nil;
~xtouch_mc_revision = nil;
~xtouch_ktlloop_revision = nil;
~xtouch_hud_revision = nil;
~mc_button_processes = nil;
~mc_process_by_element = nil;

fork {
    // Os módulos que precisam esperar apenas definem suas funções ao carregar.
    // As chamadas .value abaixo executam os waits dentro desta única Routine.
    (patch_dir +/+ "xtouch_log.scd").load;

    if (~xtouch_log_revision != expected_log_revision) {
        Error("xtouch_log.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\log);

    ~xtouch_log.value("[LOAD] log");

    (patch_dir +/+ "xtouch_device.scd").load;
    ~init_xtouch_device.value;

    if (
        ~xtm.isNil
        or: { ~xtouch_device_revision != expected_device_revision }
    ) {
        Error("xtouch_device.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\device);
    ~xtouch_log.value("[LOAD] device");

    (patch_dir +/+ "xtouch_processes.scd").load;
    ~init_xtouch_processes.value;

    if (~xtouch_processes_revision != expected_processes_revision) {
        Error("xtouch_processes.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\processes);
    ~xtouch_log.value("[LOAD] processes");

    (patch_dir +/+ "xtouch_layer_b.scd").load;

    if (~xtouch_layer_b_revision != expected_layer_b_revision) {
        Error("xtouch_layer_b.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\layer_b);
    ~xtouch_log.value("[LOAD] layer_b");

    (patch_dir +/+ "xtouch_mc.scd").load;

    if (
        ~xtouch_mc_revision != expected_mc_revision
        or: { ~mc_process_by_element.isNil }
    ) {
        Error("xtouch_mc.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\mc);
    ~xtouch_log.value("[LOAD] mc");

    (patch_dir +/+ "xtouch_ktlloop.scd").load;

    if (~xtouch_ktlloop_revision != expected_ktlloop_revision) {
        Error("xtouch_ktlloop.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\ktlloop);
    ~xtouch_log.value("[LOAD] ktlloop");

    (patch_dir +/+ "xtouch_hud.scd").load;
    ~init_xtouch_hud.value;

    if (~xtouch_hud_revision != expected_hud_revision) {
        Error("xtouch_hud.scd ausente ou incompatível.").throw;
    };
    ~xtouch_loaded_modules.add(\hud);
    ~xtouch_log.value("[LOAD] hud");

    ~xtouch_log.value(
        "X-Touch Mini r8.4: editor, mixer, router/timeline e looper carregados."
    );
};
)
