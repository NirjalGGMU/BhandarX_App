const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

const Category = require('../src/modules/categories/Category.model');
const Supplier = require('../src/modules/suppliers/Supplier.model');
const Product = require('../src/modules/products/Product.model');

const envFile = process.env.ENV_FILE || '.env.mobile';
dotenv.config({ path: path.join(__dirname, `../${envFile}`) });

const categories = [
  { code: 'SNK', name: 'Snacks', description: 'Biscuits, noodles and chips' },
  { code: 'BEV', name: 'Beverages', description: 'Cold drinks and juices' },
  { code: 'DLY', name: 'Dairy', description: 'Milk and dairy products' },
  { code: 'HOM', name: 'Household', description: 'Daily household essentials' },
  { code: 'PRS', name: 'Personal Care', description: 'Soap, shampoo and hygiene' },
  { code: 'SPC', name: 'Spices', description: 'Masala and cooking spices' },
];

const suppliers = [
  {
    code: 'KTMWHOLE',
    name: 'Kathmandu Wholesale Traders',
    email: 'ktm.wholesale@bhandarx.local',
    phone: '9800001111',
    city: 'Kathmandu',
    country: 'Nepal',
    status: 'active',
  },
];

const products = [
  { name: 'Wai Wai Noodles (Pack)', sku: 'NP-SNK-001', categoryCode: 'SNK', purchasePrice: 18, sellingPrice: 25, quantity: 40, minStockLevel: 10, unit: 'pack' },
  { name: 'Wai Wai Quick (Cup)', sku: 'NP-SNK-002', categoryCode: 'SNK', purchasePrice: 42, sellingPrice: 55, quantity: 6, minStockLevel: 8, unit: 'piece' },
  { name: 'Current Noodles', sku: 'NP-SNK-003', categoryCode: 'SNK', purchasePrice: 22, sellingPrice: 30, quantity: 0, minStockLevel: 10, unit: 'pack' },
  { name: '2PM Noodles', sku: 'NP-SNK-004', categoryCode: 'SNK', purchasePrice: 17, sellingPrice: 24, quantity: 14, minStockLevel: 8, unit: 'pack' },
  { name: 'Tiger Biscuit', sku: 'NP-SNK-005', categoryCode: 'SNK', purchasePrice: 8, sellingPrice: 10, quantity: 50, minStockLevel: 15, unit: 'piece' },
  { name: 'Digestive Biscuit', sku: 'NP-SNK-006', categoryCode: 'SNK', purchasePrice: 28, sellingPrice: 35, quantity: 5, minStockLevel: 10, unit: 'piece' },
  { name: 'Lays Chips (Small)', sku: 'NP-SNK-007', categoryCode: 'SNK', purchasePrice: 22, sellingPrice: 30, quantity: 24, minStockLevel: 8, unit: 'piece' },
  { name: 'Kurkure Masala Munch', sku: 'NP-SNK-008', categoryCode: 'SNK', purchasePrice: 16, sellingPrice: 20, quantity: 2, minStockLevel: 10, unit: 'piece' },

  { name: 'Coca Cola 500ml', sku: 'NP-BEV-001', categoryCode: 'BEV', purchasePrice: 55, sellingPrice: 70, quantity: 36, minStockLevel: 12, unit: 'piece' },
  { name: 'Fanta Orange 500ml', sku: 'NP-BEV-002', categoryCode: 'BEV', purchasePrice: 52, sellingPrice: 65, quantity: 10, minStockLevel: 10, unit: 'piece' },
  { name: 'Sprite 500ml', sku: 'NP-BEV-003', categoryCode: 'BEV', purchasePrice: 52, sellingPrice: 65, quantity: 0, minStockLevel: 10, unit: 'piece' },
  { name: 'Real Mango Juice 1L', sku: 'NP-BEV-004', categoryCode: 'BEV', purchasePrice: 118, sellingPrice: 145, quantity: 9, minStockLevel: 10, unit: 'piece' },

  { name: 'DDC Pasteurized Milk 1L', sku: 'NP-DLY-001', categoryCode: 'DLY', purchasePrice: 85, sellingPrice: 95, quantity: 12, minStockLevel: 8, unit: 'piece' },
  { name: 'DDC Ghee 500ml', sku: 'NP-DLY-002', categoryCode: 'DLY', purchasePrice: 520, sellingPrice: 610, quantity: 4, minStockLevel: 6, unit: 'piece' },
  { name: 'Paneer Local 500g', sku: 'NP-DLY-003', categoryCode: 'DLY', purchasePrice: 220, sellingPrice: 260, quantity: 0, minStockLevel: 5, unit: 'piece' },

  { name: 'Ariel Detergent 1kg', sku: 'NP-HOM-001', categoryCode: 'HOM', purchasePrice: 255, sellingPrice: 300, quantity: 11, minStockLevel: 10, unit: 'pack' },
  { name: 'Surf Excel 1kg', sku: 'NP-HOM-002', categoryCode: 'HOM', purchasePrice: 250, sellingPrice: 295, quantity: 3, minStockLevel: 10, unit: 'pack' },
  { name: 'Dishwash Bar', sku: 'NP-HOM-003', categoryCode: 'HOM', purchasePrice: 28, sellingPrice: 35, quantity: 45, minStockLevel: 12, unit: 'piece' },

  { name: 'Lifebuoy Soap', sku: 'NP-PRS-001', categoryCode: 'PRS', purchasePrice: 38, sellingPrice: 45, quantity: 28, minStockLevel: 10, unit: 'piece' },
  { name: 'Sunsilk Shampoo Sachet', sku: 'NP-PRS-002', categoryCode: 'PRS', purchasePrice: 2.8, sellingPrice: 3.5, quantity: 120, minStockLevel: 40, unit: 'piece' },
  { name: 'Colgate Toothpaste 100g', sku: 'NP-PRS-003', categoryCode: 'PRS', purchasePrice: 88, sellingPrice: 110, quantity: 7, minStockLevel: 10, unit: 'piece' },

  { name: 'Everest Garam Masala 100g', sku: 'NP-SPC-001', categoryCode: 'SPC', purchasePrice: 92, sellingPrice: 120, quantity: 13, minStockLevel: 8, unit: 'pack' },
  { name: 'Turmeric Powder 200g', sku: 'NP-SPC-002', categoryCode: 'SPC', purchasePrice: 62, sellingPrice: 80, quantity: 1, minStockLevel: 8, unit: 'pack' },
];

function imageFor(name) {
  const text = encodeURIComponent(name);
  return `https://dummyimage.com/400x300/1f8a4d/ffffff.png&text=${text}`;
}

async function seed() {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/bhandarx_inventory_mobile';
    await mongoose.connect(uri);
    console.log(`Connected: ${uri}`);

    const categoryMap = new Map();
    for (const cat of categories) {
      const doc = await Category.findOneAndUpdate(
        { code: cat.code },
        { $set: cat },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      categoryMap.set(cat.code, doc._id);
    }

    let supplierId = null;
    for (const supplier of suppliers) {
      const doc = await Supplier.findOneAndUpdate(
        { code: supplier.code },
        { $set: supplier },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      supplierId = doc._id;
    }

    let createdOrUpdated = 0;
    for (const p of products) {
      const categoryId = categoryMap.get(p.categoryCode);
      if (!categoryId || !supplierId) {
        continue;
      }
      await Product.findOneAndUpdate(
        { sku: p.sku },
        {
          $set: {
            name: p.name,
            description: `${p.name} - local Nepali retail product`,
            sku: p.sku,
            category: categoryId,
            supplier: supplierId,
            purchasePrice: p.purchasePrice,
            sellingPrice: p.sellingPrice,
            quantity: p.quantity,
            minStockLevel: p.minStockLevel,
            reorderPoint: p.minStockLevel,
            unit: p.unit,
            status: 'active',
            trackInventory: true,
            tags: ['mobile-seed', 'nepali-shop'],
            images: [imageFor(p.name)],
          },
        },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      createdOrUpdated += 1;
    }

    const total = await Product.countDocuments({});
    const low = await Product.countDocuments({
      $expr: { $lte: ['$quantity', '$minStockLevel'] },
      status: 'active',
    });
    const out = await Product.countDocuments({ quantity: 0, status: 'active' });

    console.log(`Seed done. Products upserted: ${createdOrUpdated}`);
    console.log(`Inventory status => total: ${total}, low-stock: ${low}, out-of-stock: ${out}`);
    process.exit(0);
  } catch (e) {
    console.error('Seed failed:', e);
    process.exit(1);
  }
}

seed();
