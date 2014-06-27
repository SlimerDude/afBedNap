using build
using fanr

class Build : BuildPod {

	new make() {
		podName = "afBedNap"
		summary = "A simple BedSheet application; use it to kickstart your own Bed Apps!"
		version = Version("0.0.12")

		meta = [
			"proj.name"		: "Bed Nap",
			"proj.uri"		: "http://bednap.fantomfactory.com/",
			"afIoc.module"	: "afBedNap::AppModule",
			"tags"			: "templating, testing, web",
			"repo.private"	: "false"
		]

		depends = [	
			"sys 1.0", 
			"concurrent 1.0",
			"util 1.0",
			"fandoc 1.0",

			// ---- Core ------------------------
			"afConcurrent 1.0.6+", 
			"afIoc 1.6.4+", 
			"afIocConfig 1.0.8+", 
			"afIocEnv 1.0.6+", 

			// ---- Web -------------------------
			"afBedSheet 1.3.10+", 
			"afEfan 1.4.0.1+",
			"afEfanXtra 1.1.6+",
			"afPillow 1.0.10+",
			"afSlim 1.1.8+",
			"afColdFeet 1.2.0+",
			"afDuvet 0.0.4+",
			"afGoogleAnalytics 0.0.4+",
	
			// ---- Test ------------------------
			"afBounce 1.0.4+",
			"afButter 0.0.6+",
			"afSizzle 1.0.0+",
			"xml 1.0"
		]

		srcDirs = [`test/`, `fan/`]
		resDirs = [`doc/pod.fandoc`, `doc/about.fdoc`, `etc/`, `etc/components/`, `etc/fan/`, `etc/pages/`, `etc/samples/`, `etc/web/`, `etc/web/css/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Heroku pre-compile hook, use to install dependencies" }
	Void herokuPreCompile() {
		pods := depends.findAll |Str dep->Bool| {
			depend := Depend(dep)
			pod := Pod.find(depend.name, false)
			return (pod == null) ? true : !depend.match(pod.version)
		}
		installFromRepo(pods, "http://repo.status302.com/fanr/")
	}

	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		resDirs = resDirs.addAll(srcDirs)
		super.compile
	}
	
	private Void installFromRepo(Str[] pods, Str repo) {
		cmd := "install -errTrace -y -r ${repo}".split.add(pods.join(","))
		log.info("")
		log.info("Installing pods...")
		log.indent
		log.info("> fanr " + cmd.join(" ") { it.containsChar(' ') ? "\"$it\"" : it })
		status := fanr::Main().main(cmd)
		log.unindent
		// abort build if something went wrong
		if (status != 0) Env.cur.exit(status)
	}
}
