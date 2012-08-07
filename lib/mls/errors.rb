class MLS::Exception < Exception
end

class MLS::BadRequest < MLS::Exception
end

class MLS::Unauthorized < MLS::Exception
end

class MLS::NotFound < MLS::Exception
end

class MLS::ApiVersionUnsupported < MLS::Exception
end

class MLS::RecordInvalid < MLS::Exception
end

