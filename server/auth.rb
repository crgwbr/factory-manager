require 'jwt'

HMAC_SECRET = 'my$ecretK3y'

module Auth
    def Auth.check(username, password)
        return (username == 'crgwbr' and password == '123')
    end

    def Auth.encode_token(username)
        payload = {'username' => username}
        return JWT.encode(payload, HMAC_SECRET, 'HS256')
    end

    def Auth.decode_token(token)
        begin
            decoded_token = JWT.decode(token, HMAC_SECRET)
            return decoded_token[0]['username']
        rescue
            return nil
        end
    end
end
