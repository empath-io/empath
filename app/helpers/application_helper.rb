module ApplicationHelper

	def trigger_begins_on_date_or_today_as_string(trigger)
		unless trigger.start_month && trigger.start_day && trigger.start_year
			return Date.today.strftime("%m/%d/%Y")
		else
			return "#{trigger.start_month}/#{trigger.start_day}/#{trigger.start_year}"
		end
	end

	# To enable form helpers alongside shallow routes
	# From http://stackoverflow.com/questions/9772588/when-using-shallow-routes-different-routes-require-different-form-for-arguments
	def shallow_args(parent, child)
	  child.try(:new_record?) ? [parent, child] : child
	end

	def obj_has_errors(obj)
		if obj.errors.any?
			return 1
		else		
			return 0
		end
	end

	def is_controller(name)
		if params[:controller] == name
			return true
		else
			return false
		end
	end

	def is_action(name)
		if params[:action] == name
			return true
		else
			return false
		end
	end

	# Pass start:Fixnum in the options hash to set the first drop down selection
	# from: http://stackoverflow.com/questions/5415430/time-select-form-helper-with-12-hour-format-for-rails-3
	def am_pm_hour_select(object, method, options = {}, html_options = {})
		select_options = [ ["6am", 6], ["7am", 7], ["8am", 8], ["9am", 9], ["10am", 10], ["11am", 11], ["12pm", 12], ["1pm", 13], ["2pm", 14], ["3pm", 15], ["4pm", 16], ["5pm", 17], ["6pm", 18], ["7pm", 19], ["8pm", 20], ["9pm", 21], ["10pm", 22], ["11pm", 23], ["12am", 24], ["1am", 1], ["2am", 2], ["3am", 3], ["4am",4 ], ["5am", 5]]
		unless options[:start].nil?
		  shift_if_needed = Proc.new{|hour, start| hour<start ? hour+24 : hour}
		  select_options.sort!{|x, y| shift_if_needed.call(x.last,options[:start]) <=> shift_if_needed.call(y.last, options[:start]) }
		end

		object.select(method, select_options, options = {}, html_options = {})
	end

	def begin_jarvis_widget
		return '
		  <!-- widget content -->
		  <div class="widget-body">

		  <section id="" class="">

		  <!-- row -->
		  <div class="row">

		  <!-- NEW WIDGET START -->
		  <article class="col-xs-12 col-sm-12 col-md-12 col-lg-12">

		  <!-- Widget ID (each widget will need unique ID)-->
		  <div class="jarviswidget jarviswidget-color-blueDark" id="wid-id-0" data-widget-editbutton="false">
		  '.html_safe
	end

	def end_jarvis_widget
		return '</div><!-- end jarvis-widget -->
				</article>
				</div><!-- end .row -->
				</section>
				</div><!-- end .widget-body -->'.html_safe
	end

	# Be sure that locals_hash arg is a hash that includes the local variable that you want to show e.g. {:user => @user}
	def return_js_for_show_modal(dir,locals_hash)
		return_modal_js(dir,{:show_form => false}.merge(locals_hash))
	end

	def return_js_for_edit_modal(dir,locals_hash)
		return_modal_js(dir,{:show_form => true}.merge(locals_hash))
	end	

	def return_modal_js(dir,locals_hash)
		l_hash = { :show_modal => true}.merge!(locals_hash)
		partial_str = escape_javascript(render :partial => "#{dir}/modal", :locals => l_hash )
		return "$('#modal-wrapper').html('#{partial_str}');"
	end

	def return_js_for_replacing_collection_partial(id,collection)
		puts "********Collection size is: #{collection.count}"
		partial_str = escape_javascript( render collection )
		return "$('#{id}').html('#{partial_str}');"
	end

	def create_charge_button(booking,container,id_name="",class_name="")
		button_content = '<i class="fa fa-lg fa-fw fa-credit-card"></i>'
		resource_button(booking_path(booking),button_content,container,"Create a charge",id_name,class_name,{})
	end

	def show_resource_button(route,container,popover_content,id_name='',class_name='')
		button_content = '<i class="fa fa-lg fa-fw fa-search-plus"></i>'
		resource_button(route,button_content,container,popover_content,id_name,class_name,{})
	end

	def edit_resource_button(route,container,popover_content,id_name='',class_name='')
		button_content = '<i class="fa fa-lg fa-fw fa-pencil"></i>'
		resource_button(route,button_content,container,popover_content,id_name,class_name,{})
	end

	def destroy_resource_button(route,container,popover_content,id_name='',class_name='')
		button_content = '<i class="fa fa-lg fa-fw fa-trash-o"></i>'
		resource_button(route,button_content,container,popover_content,id_name,class_name,{confirm: 'Are you sure?'},'delete')
	end


	def resource_button(route,button_content,container,popover_content,id_name='',class_name='',d_hash={},method="get",remote=true,disabled=false)
		data_hash = { :container=>container, :toggle=>"popover", :placement=>"top", :content=>popover_content,:trigger => 'hover' }.merge(d_hash)
	    button_to route, :method => method.downcase, remote: remote, disabled: disabled, class: "btn btn-default btn-small #{class_name}", id: id_name, data: data_hash do 
	      button_content.html_safe
	    end
	end	

end