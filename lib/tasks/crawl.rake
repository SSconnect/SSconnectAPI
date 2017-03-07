namespace :crawl do
  task :rss => :environment do
    Blog.all.each do |blog|
      puts blog.title
      feed = Feedjira::Feed.fetch_and_parse(blog.rss)
      feed.entries.each do |entry|
        next if Article.where(url: entry.url).exists?
        article = blog.articles.create(
            title: entry.title,
            url: entry.url,
            posted_at: entry.last_modified
        )
        doc = Nokogiri::HTML(open(article.url))
        p doc.css(blog.selector).map {|a| a.text}
      end
    end
  end
end
