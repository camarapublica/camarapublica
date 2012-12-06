task :getprojects => :environment do
	require "open-uri"
	since= Time.now-1.month
	url = "http://www.senado.cl/wspublico/tramitacion.php?fecha="+since.strftime("%d/%m/%Y");
	doc = Nokogiri::XML(open(url))
	puts "BUSCANDO NUEVOS PROYECTOS DE LEY ("+url+")";
	projects = doc.xpath('//proyectos/proyecto').map do |p|
		project=Project.new(:remoteid=>p.xpath("descripcion/boletin").inner_text)
		puts "new project: "+project.remoteid if project.save
	end
	
end
task :updateremotedata => :environment do
	Project.last.fetchdata
end