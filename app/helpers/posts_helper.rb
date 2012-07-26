module PostsHelper

  def render_post(post)
    class_name = post.class.name.underscore
    render :partial => "#{class_name.pluralize}/#{class_name}", :locals => { class_name.to_sym => post }
  end

end
