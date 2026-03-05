function lovr.conf(CONFIG)
	CONFIG.version				= "0.18.0"
	CONFIG.identity				= "default"

	CONFIG.saveprecedence		= true

	CONFIG.modules.audio		= true
	CONFIG.modules.data			= true
	CONFIG.modules.event		= true
	CONFIG.modules.graphics		= true
	CONFIG.modules.headset		= false
	CONFIG.modules.math			= true
	CONFIG.modules.physics		= true
	CONFIG.modules.system		= true
	CONFIG.modules.thread		= true
	CONFIG.modules.timer		= true

	CONFIG.audio.spatializer	= nil
	CONFIG.audio.samplerate		= 48000
	CONFIG.audio.start			= true

	CONFIG.graphics.debug		= false
	CONFIG.graphics.vsync		= true
	CONFIG.graphics.stencil		= false
	CONFIG.graphics.antialias	= true
	CONFIG.graphics.shadercache	= true

	CONFIG.headset.drivers		= {
		"openxr",
		"simulator",
	}
	CONFIG.headset.start		= true
	CONFIG.headset.supersample	= false
	CONFIG.headset.seated		= false
	CONFIG.headset.mask			= true
	CONFIG.headset.antialias	= true
	CONFIG.headset.stencil		= false
	CONFIG.headset.submitdepth	= true
	CONFIG.headset.overlay		= false

	CONFIG.math.globals			= true

	CONFIG.thread.workers		= -1

	CONFIG.window.width			= 1080
	CONFIG.window.height		= 600
	CONFIG.window.fullscreen	= false
	CONFIG.window.resizable		= false
	CONFIG.window.title			= "LÖVR"
	CONFIG.window.icon			= nil
end