# encoding: utf-8
require "open-uri"
class Project < ActiveRecord::Base
	include PgSearch
	include ActionView::Helpers::TextHelper
	has_many :updates
	has_many :comments
	has_many :votes
	attr_accessible :remoteid, :score, :title, :updated_at, :submitted_at, :last_discussed, :status, :statusdescription
	pg_search_scope :search, :against => [:title, :statusdescription, :remoteid],:ignoring => :accents, :order_within_rank => "last_discussed ASC, id DESC"
	validates_uniqueness_of :remoteid

  def fetch
    api.fetch_project(remoteid)
  end

	def fetchdata
    project_data = fetch
    tramites = project_data.delete(:tramites)
    
		self.update_attributes(project_data)
		if self.last_discussed.nil? then
      self.update_attributes(last_discussed: submitted_at)
    end

		tramites.each do |tramite|
			self.updates.destroy_all # at some point we'll want to keep the updates
			update = self.updates.new(tramite)
			self.update_attributes(last_discussed: update.date) if update.date > last_discussed
			puts "+ update: #{update.inspect}" if update.save
		end
    
		puts self.inspect
	end
	def statusname
		if self.updates.length>0
			self.updates.order("date").last.statusdescription
		else
			"Ingresado"
		end
	end
	def statuscolor
		statuscolors=["default","success","important"]
		return statuscolors[self.status]
	end
	def scorecolor
		if self.score>0
			"success"
		elsif self.score<0
			"important"
		else
			"default"
		end
	end
	def announce
		if Rails.env.production?
			begin
				bitly=Bitly.new("donemiterio", "R_3d38b50740671572e08dfd08f8cd4741")
				Twitter.update(truncate(self.title, :length=>120)+" "+bitly.shorten('http://camarapublica.cl/projects/'+self.id.to_s).short_url)
			rescue
				puts "Twitter Error"
			end
		end
	end
	def updatescore
		score=0
		self.votes.each do |v|
			score=score+v.score
		end
		self.update_attributes(:score=>score)
		return score
	end
  
  private
    def api
      @api ||= SenadoAPI.new
    end
end