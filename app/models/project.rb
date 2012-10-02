# encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	attr_accessible :remoteid, :score, :title
	validates_uniqueness_of :remoteid
	def fetchdata
		url="http://sil.senado.cl/cgi-bin/sil_proyectos.pl?"+self.remoteid
		doc = Nokogiri::HTML(open(url).read)
		puts "BUSCANDO INFO PARA PROYECTO"+self.remoteid
		i=0
		tds=doc.css('td[@bgcolor="#f6f6f6"]')
		self.update_attributes(:title=>tds[1].text)
	end
	def statusname
		statusnames=["en discusión","publicado","detenido"]
		statusnames[self.status]
	end
	def statuscolor

	end
end