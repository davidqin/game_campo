class HallObserver < ActiveRecord::Observer
  observe :room

	def after_save model
	  publish :save, model
	end

	protected

	def publish action, model
    puts "#{action}-#{model}"
	end
end
