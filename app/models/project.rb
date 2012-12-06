# encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	attr_accessible :remoteid, :score, :title, :updated_at
	validates_uniqueness_of :remoteid
	def fetchdata
		url="http://www.senado.cl/wspublico/tramitacion.php?boletin="+self.remoteid.split("-")[0]
		doc = Nokogiri::XML(open(url))
		puts "BUSCANDO INFO PARA PROYECTO "+self.remoteid+" ("+url+")"
		p=doc.xpath("//proyectos/proyecto")
		self.update_attributes(:title=>p.xpath("descripcion/titulo").inner_text,:statusdescription=>)
	end
	def statusname
		statusnames=["en discusión","publicado","detenido"]
		statusnames[self.status]
	end
	def statuscolor
		statuscolors=["default","success","important"]
	end
end