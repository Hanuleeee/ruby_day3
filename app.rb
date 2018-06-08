require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'rest-client'
require 'nokogiri'

get '/' do
    erb :app
end

get '/numbers' do
   erb :numbers 
end

get '/calculate' do
    num1 = params[:n1].to_i
    num2 = params[:n2].to_i
    @sum = num1 + num2
    @min = num1 - num2
    @mul = num1 * num2
    @div = num1 / num2
    erb :calculate
end

get '/form' do
    erb :form
end

id = "multi"
pw = "campus"

post '/login' do      #get을 post로 바꿈(post를 쓰면 위에 주소창에 정보안뜸)
    if id.eql?(params[:id])
        #비밀번호를 체크하는 로직
        if pw.eql?(params[:password])
            redirect '/complete' # 2바퀴도는데 view가 없으니까 다시 redirect로 '/complete'
        else
            @msg = "비밀번호가 틀립니다."
            redirect '/error?err_co=2'   # 한바퀴돌고 나면 서버랑 연결 끊김(초기화) thus, 아이디가 틀렸네, 비밀번호가 틀렸네 상세히 못알려줌
        end
    else
        # ID가 존재하지 않습니다
        @msg = "ID가 존재하지 않습니다."
        redirect '/error?err_co=1'
    end
end
#계정이 존재하지 않는 경우
get '/error' do
    # 다른 방식으로 에러메시지를 보여줘야함
    if params[:err_co].to_i ==1
    # id가 없는 경우
    @msg = "ID가 없습니다."
    elsif params[:err_co].to_i ==2
    # pw가 틀린 경우
    @msg = "비밀번호가 틀렸습니다."
    end
    erb :error 
end

get '/complete' do
    erb :complete
end

# get
get '/search' do
    erb :search
end

# POST
post '/search' do
    puts params[:engine]
    case params[:engine]
    when "naver"
        url = URI.encode("https://search.naver.com/search.naver?query=#{params[:query]}")
        redirect url
        #redirect "https://search.naver.com/search.naver?query=#{params[:query]}"
    when "google"
        url = URI.encode("https://www.google.co.kr/search?q=#{params[:q]}")
        redirect url
    end
end

get '/op_gg' do
    # 검색을 했을때 userName이 있으면 검색결과를 보여주고 없으면 그 페이지에 있는 로직
    if params[:userName]
        # 검색결과를 보여주는 로직
        case params[:search_method]
        # op.gg에서 승/패 수만 크롤링하여 보여줌
        when "self"
            # RestClient를 통해 op.gg에서 검색결과 페이지를 크롤링
            url = RestClient.get(URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}"))
            # 검색결과 페이지 중에서 win과 lose 부분을 찾음
            result = Nokogiri::HTML.parse(url)
            # nokogiri를 이용하여 원하는 부분을 골라냄(css문법으로 내가 원하는 걸 찾아냄)
            win = result.css('span.win').first
            lose = result.css('span.lose').first
            # 검색결과를 페이지에서 보여주기 위한 변수 선언
            @win = win.text
            @lose = lose.text
            
        # 검색결과를 op.gg에서 보여줌
        when "opgg"
            url =URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}")
            redirect url
        end
    end
    erb :op_gg
end