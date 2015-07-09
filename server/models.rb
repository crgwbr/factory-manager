require 'data_mapper'

module APIResource
    def to_api_record
        field_names = self.list_api_record_fields()

        value = Proc.new do |field|
            field.respond_to?('to_api_record') ? field.to_api_record() : field
        end

        record = {}
        for name in field_names
            field = self.send(name)

            if field.respond_to?('map')
                record[name] = field.map { |item| value.call(item) }
            else
                record[name] = value.call(field)
            end
        end

        return record
    end

    def list_api_record_fields
        return []
    end
end


class Factory
    include DataMapper::Resource
    include APIResource

    property :id, Serial
    property :name, String
    property :email, String
    property :address, Text
    has n, :factoryTags
    has n, :tags, :through => :factoryTags

    def list_api_record_fields
        return ['id', 'name', 'email', 'address', 'tags']
    end

    def update_from_api_record(record)
        for name in ['name', 'email', 'address']
            if record.has_key?(name)
                self.send(name + '=', record[name])
            end
        end

        if not record.has_key?('tags')
            return
        end

        self.tags = []
        for tag_name in record['tags']
            tag_name = tag_name.strip()
            tag = Tag.first(:name => tag_name)
            if not tag
                tag = Tag.create(:name => tag_name)
            end
            self.tags << tag
        end
    end

    def remove
        self.tags = []
        self.save()
        return self.destroy()
    end
end


class Tag
    include DataMapper::Resource
    include APIResource

    property :id, Serial
    property :name, String
    has n, :factoryTags
    has n, :factories, :through => :factoryTags

    def to_api_record
        return self.name
    end
end


class FactoryTag
    include DataMapper::Resource

    property :id, Serial
    belongs_to :factory
    belongs_to :tag
end
