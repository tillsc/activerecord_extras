# ActiveRecord Extras

**ActiveRecord Extras** provides helpful utility methods and query extensions for ActiveRecord models.
It focuses on building SQL subqueries for `has_many` associations using `EXISTS` and `COUNT`, while keeping full composability within ActiveRecord queries.

---

## Features

- `exists_association` and `count_association` methods for Arel-based subqueries
- Scopes:
  - `with_existing(:association)`
  - `without_existing(:association)`
- Extended select support:
  - `with_counts(:association)` — includes counts in result sets
  - Accepts optional block for filtering join conditions
- Fully composable ActiveRecord relations
- No monkey-patching, Rails 6+ compatible

---

## Installation

Add to your `Gemfile`:

```ruby
gem "activerecord_extras"
```

Then run:

```bash
bundle install
```

Or install manually:

```bash
gem install activerecord_extras
```

---

## Usage

### `with_existing` and `without_existing`

```ruby
User.with_existing(:posts)
User.without_existing(:comments)
```

### `with_counts`

Adds a `SELECT COUNT(*)` subquery per association:

```ruby
User.with_counts(:posts)
```

Supports filtering via block:

```ruby
User.with_counts(:posts) do |join_condition, posts|
  join_condition.and(posts[:published].eq(true))
end
```

This produces SQL like:

```sql
SELECT users.*, (
  SELECT COUNT(*) FROM posts
  WHERE posts.user_id = users.id AND posts.published = TRUE
) AS posts_count
```

---

## API Reference

### `exists_association(association_name, &block)`

Returns an Arel EXISTS subquery.

### `count_association(association_name, &block)`

Returns a grouped COUNT(*) Arel subquery.

### `with_counts(*association_names, &block)`

Selects all columns from the model and adds one COUNT subquery per named association. The optional block modifies join conditions.

---

## Development

```bash
bundle exec rake test
```

Tests use SQLite in-memory schema and require no database setup.

---

## License

MIT License © [Till Schulte-Coerne](https://github.com/tillsc)
