require "bundler/setup"
require "sinatra/base"
require "upnp/ssdp"
require "net/http"
require "uri"
require "active_support/all"
require "i18n"
require "pry"
require_relative "lib/wemo"
UPnP.log = false

class WemoAPI

	def self.scan(urn = "urn:Belkin:device:controllee:1")
		results = []
		Wemo::Radar.new(urn).scan.each do |obj|
			results.push(WemoAPI.new(obj))
		end
		results
	end

	attr_accessor :object, :name, :macaddress, :state

	def initialize(wemo)
		self.object = wemo
		self.name = wemo.attributes["root"]["device"]["friendlyName"]
		self.macaddress = wemo.attributes["root"]["device"]["macAddress"]
		self.state = getState wemo.attributes["root"]["device"]["binaryState"]
	end

	def toggle
		if self.state == "on"
			self.off
		else
			self.on
		end

		true
	end

	def on
		false if self.state == "on"
		self.object.set! 'on'
		self.state = "on"
		true
	end

	def off
		false if self.state == "off"
		self.object.set! 'off'
		self.state = "off"
		true
	end

	private
		def getState(state)
			(state || self.state).to_i == 0 ? "on" : "off"
		end
end