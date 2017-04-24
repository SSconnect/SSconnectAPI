module Entity
  class StoryEntity < Grape::Entity
    expose :id
    expose :title
    expose :first_posted_at
    expose :tag_list
    expose :articles, using: ArticleEntity
  end
end