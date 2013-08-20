#encoding: utf-8
task :getprojects => :environment do
	require "open-uri"
	since= Time.now-1.month
	url = "http://www.senado.cl/wspublico/tramitacion.php?fecha="+since.strftime("%d/%m/%Y");
	doc = Nokogiri::XML(open(url))
	puts "BUSCANDO NUEVOS PROYECTOS DE LEY ("+url+")";
	projects = doc.xpath('//proyectos/proyecto')
	projects.each do |p|
		boletin=p.xpath("descripcion/boletin").inner_text
		project=Project.new(:remoteid=>boletin)
		if project.save
			puts "new project: "+project.remoteid
			project.fetchdata
			project.announce
		else
			Project.find_by_remoteid(boletin).fetchdata
		end
	end
end
task :updateremotedata => :environment do
	Project.order("updated_at").limit(200).each do |p|
		p.fetchdata
	end
end
task :updatecongressmenkarma => :environment do
	Congressman.all.each do |c|
		karma=0
		projectsapproved=0
		efficiency=0
	  	c.projects.each do |project|
	  		karma=karma+project.score
	  		if project.status==1
	  			projectsapproved=projectsapproved+1
	  		end
	  		efficiency=((projectsapproved*100)/c.projects.count)
	  	end
	  	c.update_attributes(:efficiency=>efficiency)
	  	puts "ajustando karma para "+c.surnames+", "+c.names
	  	c.update_attributes(:karma=>karma)
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