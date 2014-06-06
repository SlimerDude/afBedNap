using build
using fanr

class Build : BuildPod {

	new make() {
		podName = "afBedNap"
		summary = "A simple BedSheet application; use it to kickstart your own Bed Apps!"
		version = Version("0.0.10")

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

			// core Ioc
			"afConcurrent 1.0.4+", 
			"afIoc 1.6.2+", 
			"afIocConfig 1.0.6+", 
			"afIocEnv 1.0.4+", 

			// web stuff
			"afBedSheet 1.3.6+", 
			"afEfan 1.4.0.1+",
			"afEfanXtra 1.1.4+",
			"afPillow 1.0.8+",
			"afSlim 1.1.4+",
	
			// for testing
			"afBounce 1.0.0+",
			"afButter 0.0.6+",
			"afSizzle 1.0.0+",
			"xml 1.0"
		]

		srcDirs = [`test/`, `fan/`]
		resDirs = [`licence.txt`, `doc/`, `etc/`, `etc/components/`, `etc/fan/`, `etc/pages/`, `etc/samples/`, `etc/web/`, `etc/web/css/`]

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
