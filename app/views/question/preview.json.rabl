
# Returned json : { :preview => { :id => '1-4hy-9020j', :scans => [0,1,2,3] } }
# This form is in keeping with what is used in quizzes/preview & 
# quizzes/get_candidates

object false
  node(:preview) { 
    {
      source: :vault,
      images: @question.preview_images(@version)
    }
  }

  node(:context) { @context }
  node(:a) { @question.id }
  node(:b) { @question.uid }

  node(:video, unless: lambda{ |m| @question.video.nil? }) do |m| 
    @question.video.uid
  end
