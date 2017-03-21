namespace :crawl do
  task :rss => :environment do
    Blog.all.each do |blog|
      # rss未設置
      next if blog.rss.nil?
      puts blog.title
      feed = Feedjira::Feed.fetch_and_parse(blog.rss)
      feed.entries.each do |entry|
        # SKIP 登録済み
        next if Article.where(url: entry.url).exists?
        # HACK: SKIP 絵文字入り
        next if entry.title.each_char.select { |c| c.bytes.count >= 4 }.length > 0
        story = Story.find_or_create_by(title: entry.title)
        story.articles.create(
            url: entry.url,
            posted_at: entry.last_modified,
            blog: blog
        )
        if story.last_posted_at.nil?
          story.last_posted_at = entry.last_modified
        else
          story.last_posted_at = [story.last_posted_at, entry.last_modified].max
        end
        story.save
        print(story.last_posted_at)

        doc = Nokogiri::HTML(open(entry.url))
        next if doc.css(blog.selector)[0].nil? # TODO: Notification Selector invalid Erorr
        if blog.id == 3
          story.regist_tag(doc.css('dd a').map(&:text))
        else
          story.regist_tag(doc.css(blog.selector)[0].text)
        end
        p story.tag_list.join(', ')
      end

    end
  end
end
