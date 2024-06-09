require 'elasticsearch/model'
class Message < ApplicationRecord
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    # Custom indexing for specific fields
    settings index: { 
        number_of_shards: 1,
        analysis: {
          filter: {
            ngram_filter: {
              type: "ngram",
              min_gram: 3,
              max_gram: 3
            }
          },
          analyzer: {
            ngram_analyzer: {
              type: "custom",
              tokenizer: "standard",
              filter: ["lowercase", "ngram_filter"]
            },
          }
        }
        } do
        mappings dynamic: 'false' do
            indexes :chat_id, type: :integer
            indexes :body, type: :text, analyzer: 'ngram_analyzer'
        end
    end

    belongs_to :chat, foreign_key: :chat_id
    
    def as_indexed_json(options = nil)
        self.as_json( only: [ :chat_id, :body ] )
    end      
  

    def self.search(body, chat_id)
        params = {
            query: {
                bool: {
                    must: [
                    {
                        terms: {
                        chat_id: [chat_id.to_i]
                        }
                    },
                    {
                        wildcard: {
                            body: "*#{body}*"
                        }
                    }
                    ]
                }
            }
        }

        self.__elasticsearch__.search(params).records
    end
end
