class MLSGem::Exception < Exception
end

class MLSGem::Exception::UnexpectedResponse < MLSGem::Exception
end

class MLSGem::Exception::BadRequest < MLSGem::Exception
end

class MLSGem::Exception::Unauthorized < MLSGem::Exception
end

class MLSGem::Exception::NotFound < MLSGem::Exception
end

class MLSGem::Exception::Gone < MLSGem::Exception
end

class MLSGem::Exception::MovedPermanently < MLSGem::Exception
end

class MLSGem::Exception::ApiVersionUnsupported < MLSGem::Exception
end

class MLSGem::Exception::RecordInvalid < MLSGem::Exception
end

class MLSGem::Exception::ServiceUnavailable < MLSGem::Exception
end
