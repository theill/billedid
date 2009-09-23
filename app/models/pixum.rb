require 'net/http'
require 'uri'

class Pixum
  def transfer(photo)
    token = '40a9ce97b06745aecf9b6e61307fb63c'
    
    h = Net::HTTP.new('www.pixum.de')
    rsp, data = h.get2("/uploadApiSessionRequest/51/#{token}")
    
    rsp.body.strip!
    
    if (rsp.body.match(/error=(.*)/)[1] == "0")
      upload_url = rsp.body.match(/uploadurl=(.*)/)[1]
      
      binary_image = File.read("#{RAILS_ROOT}/tmp/#{photo.full_filename(:final)}")
      
      # url = URI.parse(upload_url)
      # h = Net::HTTP.new(url.host, url.port)
      # rsp, data = h.post(url.path, binary_image, { 'content-type' => 'multipart/form-data' })
      
      session_token = upload_url.match(/sessionToken=([^&]+)/)[1]
      
      upload_url = upload_url.match(/(.*)\?(.*)/)[1]
      
      image_file = File.open("#{RAILS_ROOT}/tmp/#{photo.full_filename(:final)}", 'rb')
      params = { 'sessionToken' => session_token, 'token' => token, 'ImageData' => image_file }
      mp = Multipart::MultipartPost.new
      query, headers = mp.prepare_query(params)
      image_file.close
      # Make sure the URL is useable
      url = URI.parse(upload_url)
      
      # Do the actual POST, given the right inputs
      Net::HTTP.start(url.host, url.port) do |con|
        con.read_timeout = 1000
        begin
          res = con.post(url.path, query, headers)
          res.body.match(/clickurl=(.*)/)[1].strip
        rescue => e
          "POSTING Failed #{e}... #{Time.now}"
        end
      end

      # # res holds the response to the POST
      # case res
      # when Net::HTTPSuccess
      #   puts "Hooray"
      # when Net::HTTPInternalServerError
      #   raise "Server blew up"
      # else
      #   raise "Unknown error #{res}: #{res.inspect}"
      # end      
      
      # mp = Multipart.new({'ImageData' => "#{RAILS_ROOT}/tmp/#{photo.full_filename(:final)}"})
      # mp.post(upload_url)
      
      # test with "gem install multipart-port"
      # require 'net/http/post/multipart'
      # url = URI.parse(upload_url)
      # jpg = File.open("#{RAILS_ROOT}/tmp/#{photo.full_filename(:final)}")
      # req = Net::HTTP::Post::Multipart.new url.path, {'sessionToken' => session_token, 'token' => token, 'ImageData' => UploadIO.new(jpg, "image/jpeg", "#{RAILS_ROOT}/tmp/#{photo.full_filename(:final)}")}
      # res = Net::HTTP.start(url.host, url.port) do |http|
      #   http.request(req)
      # end
      
      
      
      # req = Net::HTTP::Post.new(url.path)
      # req.set_form_data({'content-type'=>'text/plain', 'charset'=>'utf-8'}, ';')
      # res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      # case res
      # when Net::HTTPSuccess, Net::HTTPRedirection
      #   # OK
      # else
      #   res.error!
      # end      
    end
    
  end
end