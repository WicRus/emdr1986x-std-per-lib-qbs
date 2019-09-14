import qbs
import qbs.FileInfo
import qbs.ModUtils

CppApplication {

    name: "milandr-firmware"
    type: [
        "application",
        "bin",
        "hex",
    ]

    Depends {
        name: "cpp"
    }

    consoleApplication: true
    cpp.positionIndependentCode: false
    cpp.executableSuffix: ".elf"

    property string  cpu_name : "E1"

    property var cpu_conf: ({   E1: "MDR1986VE1T",
                                E3: "MDR1986VE3",
                                E4: "MDR1986BE4",
                                E8: "MDR1986VE8T",
                                E9: "MDR1986VE9x",
                                C1: "MDR1901VC1T"})

    property var core_conf: ({  E1: "m1",
                                E3: "m1",
                                E4: "m0",
                                E8: "m4",
                                E9: "m3",
                                C1: "m3"})

    property var periph_conf: ({E1: "MDR32F9Qx_StdPeriph_Driver",
                                E3: "MDR32F9Qx_StdPeriph_Driver",
                                E4: "MDR1986BE4_StdPeriph_Driver",
                                E8: "MDR32F8_StdPeriph_Driver",
                                E9: "MDR32F9Qx_StdPeriph_Driver",
                                C1: "MDR32F9Qx_StdPeriph_Driver"})

    property string cpu: cpu_conf[cpu_name]
    property string core: core_conf[cpu_name]
    property string periph: periph_conf[cpu_name]

    property string home_path: path + "/"
    property string cmsis_path: home_path + "/CMSIS/" + core
    property string inc_coresupport_path: cmsis_path + "/CoreSupport"
    property string inc_devicesupport_startup_path: cmsis_path + "/DeviceSupport/" + cpu + "/startup"
    property string inc_devicesupport_path: cmsis_path + "/DeviceSupport/" + cpu + "/inc"
    property string periphery_path: home_path + "/" + periph
    property string inc_periphery_path: periphery_path + "/inc"
    property string inc_periphery_usb_path: periphery_path + "/inc/USB_Library"
    property string inc_config_path: home_path + "/Config"

    property string app_path: home_path + "/app"

    Group {
        name: "app"
        files: [
            app_path + "/**/*",
            app_path + "/*",
        ]
    }

    Group {
        name: "libs"
        files: [
            periphery_path + "/**/*.h",
            periphery_path + "/**/*.c",
            inc_devicesupport_startup_path + "/gcc/*.S",
        ]
        excludeFiles: [

        ]
        cpp.cxxFlags: [ "-std=c++11" ]
        cpp.cFlags: [ "-std=gnu99" ]
    }

    Group {
        name: "config"
        files: [
            inc_config_path + "/**",
        ]
    }
    Group {
        name: "openocd"
        files: [
            home_path + "/openocd/" + cpu_conf[cpu_name] + ".cfg",
        ]
    }

    cpp.includePaths: [

        cmsis_path,
        periphery_path,
        app_path,
        inc_coresupport_path,
        inc_devicesupport_startup_path,
        inc_devicesupport_path,
        inc_periphery_path,
        inc_periphery_usb_path,
        inc_config_path,
    ]

        cpp.defines: [
    ]

    cpp.commonCompilerFlags: [
        "-mcpu=cortex-"+core,
        "-mthumb",
        "-ffunction-sections",
        "-fdata-sections",
        "-pipe",
        "-DUSE_" + cpu,
        "-D__STARTUP_CLEAR_BSS",
        "-D_start=main"
    ]

    cpp.driverFlags: [
        "-mcpu=cortex-"+core,
        "-mthumb",
        "-Xlinker",
        "--gc-sections",
        "-specs=nosys.specs",
        "-specs=nano.specs",
        "-ffreestanding",
        "-nostartfiles",
    ]

    cpp.linkerFlags: [
        "--start-group",
        "-T" + inc_devicesupport_startup_path + "/gcc/" + cpu + ".ld",
    ]

    cpp.libraryPaths: [

    ]

    cpp.staticLibraries: [

    ]

    Properties {
        condition: qbs.buildVariant === "debug"
        cpp.debugInformation: true
        cpp.optimization: "none"
    }

    Properties {
        condition: qbs.buildVariant === "release"
        cpp.debugInformation: false
        cpp.optimization: "small"
    }

    Properties {
        condition: cpp.debugInformation
        cpp.defines: outer.concat("DEBUG")
    }

    Group {
        fileTagsFilter: product.type
        qbs.install: true
    }

    Rule {
        id: binDebugFrmw
        condition: qbs.buildVariant === "debug"
        inputs: ["application"]

        Artifact {
            fileTags: ["bin"]
            filePath: input.baseDir + "/" + input.baseName + ".bin"
        }

        prepare: {
            var objCopyPath = "arm-none-eabi-objcopy"
            var argsConv = ["-O", "binary", input.filePath, output.filePath]
            var cmd = new Command(objCopyPath, argsConv)
            cmd.description = "Converting to BIN: " + FileInfo.fileName(
                        input.filePath) + " -> " + input.baseName + ".bin"

            var argsFlashingInternalFlash =
            [           "-f", project.sourceDirectory + "/openocd/" + cpu_conf[cpu_name] + ".cfg",
                        "-c", "init",
                        "-c", "reset init",
                        "-c", "flash write_image erase " + input.filePath,
                        "-c", "reset",
                        "-c", "shutdown"
            ]

            var cmdFlashInternalFlash = new Command("openocd", argsFlashingInternalFlash);
            cmdFlashInternalFlash.description = "Wrtie to the internal flash"

            return [cmd, cmdFlashInternalFlash]
        }
    }

    Rule {
        id: binFrmw
        condition: qbs.buildVariant === "release"
        inputs: ["application"]

        Artifact {
            fileTags: ["bin"]
            filePath: input.baseDir + "/" + input.baseName + ".bin"
        }

        prepare: {
            var objCopyPath = "arm-none-eabi-objcopy"
            var argsConv = ["-O", "binary", input.filePath, output.filePath]
            var cmd = new Command(objCopyPath, argsConv)
            cmd.description = "converting to BIN: " + FileInfo.fileName(
                        input.filePath) + " -> " + input.baseName + ".bin"

            var argsFlashingInternalFlash =
            [           "-f", project.sourceDirectory + "/openocd/" + cpu_conf[cpu_name] + ".cfg",
                        "-c", "init",
                        "-c", "reset init",
                        "-c", "flash write_image erase " + input.filePath,
                        "-c", "reset",
                        "-c", "shutdown"
            ]

            var cmdFlashInternalFlash = new Command("openocd", argsFlashingInternalFlash);
            cmdFlashInternalFlash.description = "Wrtie to the internal flash"

            return [cmd, cmdFlashInternalFlash]
        }
    }

    Rule {
        id: hexFrmw
        condition: qbs.buildVariant === "release"
        inputs: ["application"]

        Artifact {
            fileTags: ["hex"]
            filePath: input.baseDir + "/" + input.baseName + ".hex"
        }

        prepare: {
            var objCopyPath = "arm-none-eabi-objcopy"
            var argsConv = ["-O", "ihex", input.filePath, output.filePath]
            var cmd = new Command(objCopyPath, argsConv)
            cmd.description = "converting to HEX: " + FileInfo.fileName(
                        input.filePath) + " -> " + input.baseName + ".hex"

            return [cmd]
        }
    }
}
