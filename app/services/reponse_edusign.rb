class ReponseEdusign < ApplicationService

    def initialize(http, request)
        @response = JSON.parse(http.request(request).read_body)
        puts "Initisialisation response"
    end

    def call
        @response
    end

    def error
        @response["status"] == 'error'
    end

    def get_attribut(attribut)
        @response[attribut]
    end

    

end