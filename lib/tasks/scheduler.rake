task :getprojects => :environment do
	require "open-uri"
	since= Time.now-1.month
	url = "http://www.senado.cl/wspublico/tramitacion.php?fecha="+since.strftime("%d/%m/%Y");
	doc = Nokogiri::XML(open(url))
	puts "BUSCANDO NUEVOS PROYECTOS DE LEY ("+url+")";
	projects = doc.xpath('//proyectos/proyecto').map do |p|
		boletin=p.xpath("descripcion/boletin").inner_text
		project=Project.new(:remoteid=>boletin)
		if project.save
			puts "new project: "+project.remoteid
			project.delay.fetchdata
			project.delay.announce
		else
			Project.find_by_remoteid(boletin).delay.fetchdata
		end
	end
end
task :updateremotedata => :environment do
	Project.order("updated_at").limit(200).each do |p|
		p.fetchdata
	end
end
task :getoldprojects => :environment do
	require "open-uri"
	doc = Nokogiri::HTML(open("http://camarapublica.cl/historial_proyectos.html").read)
	puts "BUSCANDO VIEJOS PROYECTOS DE LEY"
	doc.css('td[@class="TEXTpais"]').each do |td|
		remoteid=td.text.strip.chop.chop
		if project=Project.new(:remoteid=>remoteid).save
			puts "NUEVO PROYECTO:"+remoteid+". BIENVENIDO!"
		end
	end
end