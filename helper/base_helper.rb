helpers do
  def link_to url, text = url, opts={}
    attributes = ""
    opts.each { |key,value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end

  def show_errors
    html = ""

    @errors.each do |field, messages|
     html += "<strong>#{field}</strong>: #{messages.join(';')}<br>"
   end

   #"<div class=\"alert alert-error\">#{html}</div>"
   "<div class=\"alert alert-block\">
   <button type=\"button\" class=\"close\" data-dismiss=\"alert\">X</button>
   <h4>Hi! Something Wrong!</h4>
   <br>
   #{html}
   </div>"
  end
end