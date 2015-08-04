# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150514043126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "Address", force: :cascade do |t|
    t.integer  "addressType",             null: false
    t.string   "address1",    limit: 255, null: false
    t.string   "address2",    limit: 255
    t.string   "city",        limit: 255, null: false
    t.string   "state",       limit: 255, null: false
    t.string   "zip",         limit: 255, null: false
    t.integer  "status"
    t.datetime "createdAt",               null: false
    t.datetime "updatedAt",               null: false
    t.integer  "UserId"
    t.string   "phoneNumber", limit: 255, null: false
  end

  create_table "Brand", force: :cascade do |t|
    t.string   "name",      limit: 255, null: false
    t.integer  "status"
    t.datetime "createdAt",             null: false
    t.datetime "updatedAt",             null: false
    t.integer  "PartnerId"
  end

  add_index "Brand", ["PartnerId", "name"], name: "Brand_PartnerId_name_unique", unique: true, using: :btree
  add_index "Brand", ["PartnerId"], name: "fki_Brand_PartnerId_fkey_status_1", where: "(status = 1)", using: :btree

  create_table "Category", force: :cascade do |t|
    t.string   "name",      limit: 255, null: false
    t.integer  "parentId"
    t.integer  "orderBy"
    t.integer  "status"
    t.datetime "createdAt",             null: false
    t.datetime "updatedAt",             null: false
  end

  add_index "Category", ["name"], name: "Category_name_key", unique: true, using: :btree

  create_table "InvalidateProduct", id: false, force: :cascade do |t|
    t.integer "productId",             null: false
    t.integer "partnerId",             null: false
    t.string  "batchId",   limit: 255
  end

  add_index "InvalidateProduct", ["batchId"], name: "InvalidateProduct_batchId_idx", using: :btree
  add_index "InvalidateProduct", ["partnerId", "batchId"], name: "InvalidateProduct_partnerId_batchId_idx", using: :btree
  add_index "InvalidateProduct", ["partnerId"], name: "InvalidateProduct_partnerId_idx", using: :btree
  add_index "InvalidateProduct", ["productId"], name: "InvalidateProduct_productId_idx", using: :btree

  create_table "InvalidateProductCategory", id: false, force: :cascade do |t|
    t.integer "productId",             null: false
    t.integer "partnerId",             null: false
    t.string  "batchId",   limit: 255
  end

  add_index "InvalidateProductCategory", ["batchId"], name: "InvalidateProductCategory_batchId_idx", using: :btree
  add_index "InvalidateProductCategory", ["partnerId", "batchId"], name: "InvalidateProductCategory_partnerId_batchId_idx", using: :btree
  add_index "InvalidateProductCategory", ["partnerId"], name: "InvalidateProductCategory_partnerId_idx", using: :btree
  add_index "InvalidateProductCategory", ["productId"], name: "InvalidateProductCategory_productId_idx", using: :btree

  create_table "InvalidateVariant", id: false, force: :cascade do |t|
    t.integer "variantId",             null: false
    t.integer "partnerId",             null: false
    t.string  "batchId",   limit: 255
  end

  add_index "InvalidateVariant", ["batchId"], name: "InvalidateVariant_batchId_idx", using: :btree
  add_index "InvalidateVariant", ["partnerId", "batchId"], name: "InvalidateVariant_partnerId_batchId_idx", using: :btree
  add_index "InvalidateVariant", ["partnerId"], name: "InvalidateVariant_partnerId_idx", using: :btree
  add_index "InvalidateVariant", ["variantId"], name: "InvalidateVariant_variantId_idx", using: :btree

  create_table "InvalidateVariantImg", id: false, force: :cascade do |t|
    t.integer "variantImgId",             null: false
    t.integer "partnerId",                null: false
    t.string  "batchId",      limit: 255
  end

  add_index "InvalidateVariantImg", ["batchId"], name: "InvalidateVariantImg_batchId_idx", using: :btree
  add_index "InvalidateVariantImg", ["partnerId", "batchId"], name: "InvalidateVariantImg_partnerId_batchId_idx", using: :btree
  add_index "InvalidateVariantImg", ["partnerId"], name: "InvalidateVariantImg_partnerId_idx", using: :btree
  add_index "InvalidateVariantImg", ["variantImgId"], name: "InvalidateVariantImg_variantId_idx", using: :btree

  create_table "ItemCountShippingCost", force: :cascade do |t|
    t.integer  "itemCount",       null: false
    t.integer  "shippingPrice",   null: false
    t.integer  "status",          null: false
    t.datetime "createdAt",       null: false
    t.datetime "updatedAt",       null: false
    t.integer  "PartnerDetailId"
  end

  create_table "Order", force: :cascade do |t|
    t.integer  "shippingCents",                      null: false
    t.integer  "taxCents",                           null: false
    t.integer  "orderTotalCents",                    null: false
    t.string   "notes",                  limit: 255
    t.integer  "appliedCommissionCents",             null: false
    t.integer  "status",                             null: false
    t.boolean  "shareWithPublisher",                 null: false
    t.string   "apiKey",                 limit: 255, null: false
    t.string   "sourceUrl",              limit: 255
    t.datetime "createdAt",                          null: false
    t.datetime "updatedAt",                          null: false
    t.integer  "BillingAddressId"
    t.integer  "ShippingAddressId"
    t.integer  "UserId"
    t.integer  "PaymentId"
    t.float    "dequeuedAt"
  end

  add_index "Order", ["createdAt"], name: "Order_createdAt_idx_status_3", where: "(status = 3)", using: :btree
  add_index "Order", ["dequeuedAt"], name: "Order_dequeuedAt_idx_dequeuedAt_not_null", where: "(\"dequeuedAt\" IS NOT NULL)", using: :btree

  create_table "OrderItem", force: :cascade do |t|
    t.integer  "quantity",                    null: false
    t.integer  "listPriceCents"
    t.integer  "salePriceCents"
    t.datetime "createdAt",                   null: false
    t.datetime "updatedAt",                   null: false
    t.integer  "OrderId"
    t.integer  "VariantId"
    t.string   "sourceUrl",       limit: 255, null: false
    t.string   "widgetUuid",      limit: 255, null: false
    t.string   "apiKey",          limit: 255, null: false
    t.integer  "status"
    t.integer  "commissionCents",             null: false
    t.text     "notes"
  end

  create_table "Partner", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.integer  "status",                  null: false
    t.datetime "createdAt",               null: false
    t.datetime "updatedAt",               null: false
    t.integer  "commission",              null: false
    t.integer  "daysToWait"
    t.string   "policyUrl",   limit: 255
    t.string   "linkshareId", limit: 255
  end

  add_index "Partner", ["name"], name: "Partner_name_idx_status_1", where: "(status = 1)", using: :btree
  add_index "Partner", ["name"], name: "Partner_name_key", unique: true, using: :btree

  create_table "PartnerDetail", force: :cascade do |t|
    t.string   "state",             limit: 255, null: false
    t.string   "zip",               limit: 255
    t.integer  "shippingType",                  null: false
    t.integer  "salesTax",                      null: false
    t.integer  "freeShippingAbove",             null: false
    t.integer  "siteWideDiscount",              null: false
    t.integer  "status",                        null: false
    t.datetime "createdAt",                     null: false
    t.datetime "updatedAt",                     null: false
    t.integer  "PartnerId"
  end

  create_table "PartnerImport", force: :cascade do |t|
    t.datetime "LastImport", null: false
    t.datetime "createdAt",  null: false
    t.datetime "updatedAt",  null: false
    t.integer  "PartnerId"
  end

  create_table "Payment", force: :cascade do |t|
    t.integer  "type",                        null: false
    t.string   "number",          limit: 255, null: false
    t.integer  "expirationMonth",             null: false
    t.integer  "expirationYear",              null: false
    t.string   "name",            limit: 255, null: false
    t.integer  "status"
    t.datetime "createdAt",                   null: false
    t.datetime "updatedAt",                   null: false
    t.integer  "UserId"
    t.string   "cvv",             limit: 255
  end

  create_table "Product", force: :cascade do |t|
    t.string   "name",                  limit: 255, null: false
    t.text     "description",                       null: false
    t.integer  "status"
    t.string   "sku",                   limit: 255, null: false
    t.string   "colorSubstitute",       limit: 255
    t.text     "sourceUrl"
    t.integer  "pageViews"
    t.datetime "validatedAtOld"
    t.text     "searchText"
    t.datetime "createdAt",                         null: false
    t.datetime "updatedAt",                         null: false
    t.integer  "BrandId"
    t.text     "descriptionSearchText"
    t.tsvector "tsv"
    t.integer  "salePercent"
    t.integer  "minPriceCents"
    t.integer  "maxPriceCents"
    t.float    "validatedAt"
  end

  add_index "Product", ["BrandId", "createdAt"], name: "Product_BrandId_createdAt_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["BrandId"], name: "fki_Product_BrandId_fkey_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["createdAt"], name: "Product_createdAt_idx_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["maxPriceCents"], name: "Product_maxPriceCents_idx_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["minPriceCents"], name: "Product_minPriceCents_idx_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["salePercent"], name: "Product_salePercent_Desc_idx_status_1", where: "(status = 1)", using: :btree
  add_index "Product", ["sku"], name: "Product_sku_idx", using: :btree
  add_index "Product", ["tsv"], name: "tsv_idx_status_1", where: "(status = 1)", using: :gin

  create_table "ProductCategory", force: :cascade do |t|
    t.datetime "validatedAtOld"
    t.integer  "status"
    t.datetime "createdAt",      null: false
    t.datetime "updatedAt",      null: false
    t.integer  "CategoryId"
    t.integer  "ProductId"
    t.float    "validatedAt"
  end

  add_index "ProductCategory", ["CategoryId"], name: "fki_ProductCategory_CategoryId_fkey_status_1", where: "(status = 1)", using: :btree
  add_index "ProductCategory", ["ProductId"], name: "fki_ProductCategory_ProductId_fkey_status_1", where: "(status = 1)", using: :btree

  create_table "Role", force: :cascade do |t|
    t.string   "name",      limit: 255, null: false
    t.integer  "status"
    t.datetime "createdAt",             null: false
    t.datetime "updatedAt",             null: false
  end

  add_index "Role", ["name"], name: "Role_name_key", unique: true, using: :btree

  create_table "User", force: :cascade do |t|
    t.string   "email",                  limit: 255, null: false
    t.text     "password",                           null: false
    t.string   "salt",                   limit: 255
    t.string   "facebookId",             limit: 255
    t.string   "firstName",              limit: 255, null: false
    t.string   "middleName",             limit: 255
    t.string   "lastName",               limit: 255, null: false
    t.integer  "status"
    t.integer  "commissionCents"
    t.datetime "createdAt",                          null: false
    t.datetime "updatedAt",                          null: false
    t.string   "apiKey",                 limit: 255
    t.string   "url",                                             array: true
    t.integer  "pendingCommissionCents"
    t.integer  "totalCommissionCents"
    t.string   "focus",                                           array: true
  end

  add_index "User", ["facebookId"], name: "User_facebookId_key", unique: true, using: :btree

  create_table "UserRole", force: :cascade do |t|
    t.integer  "status"
    t.datetime "createdAt", null: false
    t.datetime "updatedAt", null: false
    t.integer  "RoleId"
    t.integer  "UserId"
  end

# Could not dump table "Variant" because of following StandardError
#   Unknown type 'enum_colorfamily' for column 'colorFamily'

  create_table "VariantImg", force: :cascade do |t|
    t.string   "url",            limit: 255, null: false
    t.string   "sourceUrl",      limit: 255, null: false
    t.integer  "sortOrder"
    t.datetime "validatedAtOld"
    t.integer  "status"
    t.datetime "createdAt",                  null: false
    t.datetime "updatedAt",                  null: false
    t.integer  "VariantId"
    t.float    "validatedAt"
  end

  add_index "VariantImg", ["VariantId"], name: "fki_VariantImg_VariantId_fkey", using: :btree
  add_index "VariantImg", ["VariantId"], name: "fki_VariantImg_VariantId_fkey_status_1", where: "(status = 1)", using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.text     "body"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "namespace",     limit: 255
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "brandfilters", id: false, force: :cascade do |t|
    t.string  "filtertype", limit: 7
    t.string  "filtername", limit: 255
    t.integer "filterid"
  end

  create_table "categoryfilters", id: false, force: :cascade do |t|
    t.string  "filtertype", limit: 7
    t.string  "filtername", limit: 255
    t.integer "filterid"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "partnerdetailid", id: false, force: :cascade do |t|
    t.integer "id"
  end

  create_table "partnerfilters", id: false, force: :cascade do |t|
    t.string  "filtertype", limit: 7
    t.string  "filtername", limit: 255
    t.integer "filterid"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  add_foreign_key "Brand", "\"Partner\"", column: "PartnerId", name: "Brand_PartnerId_fkey"
  add_foreign_key "Product", "\"Brand\"", column: "BrandId", name: "Product_BrandId_fkey"
  add_foreign_key "ProductCategory", "\"Category\"", column: "CategoryId", name: "ProductCategory_CategoryId_fkey"
  add_foreign_key "ProductCategory", "\"Product\"", column: "ProductId", name: "ProductCategory_ProductId_fkey"
  add_foreign_key "Variant", "\"Product\"", column: "ProductId", name: "Variant_ProductId_fkey"
  add_foreign_key "VariantImg", "\"Variant\"", column: "VariantId", name: "VariantImg_VariantId_fkey"
end
