class MLS::Exception < Exception
end

class MLS::Exception::UnexpectedResponse < MLS::Exception
end

class MLS::Exception::BadRequest < MLS::Exception
end

class MLS::Exception::Unauthorized < MLS::Exception
end

class MLS::Exception::NotFound < MLS::Exception
end

class MLS::Exception::Gone < MLS::Exception
end

class MLS::Exception::MovedPermanently < MLS::Exception
end

class MLS::Exception::ApiVersionUnsupported < MLS::Exception
end

class MLS::Exception::RecordInvalid < MLS::Exception
end

class MLS::Exception::ServiceUnavailable < MLS::Exception
end
