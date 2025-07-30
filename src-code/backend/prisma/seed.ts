import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Clear existing data (optional - for development)
  console.log('🧹 Cleaning existing data...');
  await prisma.doctor.deleteMany();
  await prisma.department.deleteMany();

  // Create departments
  console.log('🏢 Creating departments...');
  const departments = await Promise.all([
    prisma.department.create({
      data: {
        name: 'Cardiology',
        code: 'CARD',
        description: 'Heart and cardiovascular system',
      },
    }),
    prisma.department.create({
      data: {
        name: 'Pulmonology',
        code: 'PULM',
        description: 'Lungs and respiratory system',
      },
    }),
    prisma.department.create({
      data: {
        name: 'Neurology',
        code: 'NEUR',
        description: 'Brain and nervous system',
      },
    }),
    prisma.department.create({
      data: {
        name: 'Orthopedics',
        code: 'ORTH',
        description: 'Bones, joints, and musculoskeletal system',
      },
    }),
    prisma.department.create({
      data: {
        name: 'Nephrology',
        code: 'NEPH',
        description: 'Kidneys and urinary system',
      },
    }),
  ]);

  console.log(`✅ Created ${departments.length} departments`);

  // Create 5 doctors across different departments
  console.log('👨‍⚕️ Creating doctors...');
  const doctors = [
    {
      firstName: 'John',
      lastName: 'Smith',
      email: 'dr.smith@routeclouds.health',
      specialization: 'Interventional Cardiology',
      departmentId: departments[0].id, // Cardiology
      qualifications: ['MD', 'FACC', 'Board Certified Cardiologist'],
      experienceYears: 15,
      consultationFee: 200.0,
    },
    {
      firstName: 'Sarah',
      lastName: 'Johnson',
      email: 'dr.johnson@routeclouds.health',
      specialization: 'Critical Care Pulmonology',
      departmentId: departments[1].id, // Pulmonology
      qualifications: ['MD', 'FCCP', 'Pulmonary Disease Specialist'],
      experienceYears: 12,
      consultationFee: 180.0,
    },
    {
      firstName: 'Michael',
      lastName: 'Williams',
      email: 'dr.williams@routeclouds.health',
      specialization: 'Clinical Neurology',
      departmentId: departments[2].id, // Neurology
      qualifications: ['MD', 'PhD', 'Board Certified Neurologist'],
      experienceYears: 18,
      consultationFee: 220.0,
    },
    {
      firstName: 'Emily',
      lastName: 'Brown',
      email: 'dr.brown@routeclouds.health',
      specialization: 'Orthopedic Surgery',
      departmentId: departments[3].id, // Orthopedics
      qualifications: ['MD', 'FAAOS', 'Orthopedic Surgeon'],
      experienceYears: 10,
      consultationFee: 250.0,
    },
    {
      firstName: 'David',
      lastName: 'Davis',
      email: 'dr.davis@routeclouds.health',
      specialization: 'Clinical Nephrology',
      departmentId: departments[4].id, // Nephrology
      qualifications: ['MD', 'FASN', 'Kidney Disease Specialist'],
      experienceYears: 14,
      consultationFee: 190.0,
    },
  ];

  for (const doctor of doctors) {
    await prisma.doctor.create({ data: doctor });
  }

  console.log(`✅ Created ${doctors.length} doctors`);

  // Display summary
  console.log('\n📊 Database Seeding Summary:');
  console.log('================================');
  
  const departmentSummary = await prisma.department.findMany({
    include: {
      _count: {
        select: { doctors: true },
      },
    },
  });

  departmentSummary.forEach(dept => {
    console.log(`🏢 ${dept.name} (${dept.code}): ${dept._count.doctors} doctor(s)`);
  });

  console.log('\n👨‍⚕️ Doctors Created:');
  const doctorSummary = await prisma.doctor.findMany({
    include: {
      department: true,
    },
  });

  doctorSummary.forEach(doctor => {
    console.log(`   • Dr. ${doctor.firstName} ${doctor.lastName} - ${doctor.specialization} (${doctor.department.name})`);
  });

  console.log('\n🎉 Database seeding completed successfully!');
  console.log('🚀 Ready to start the API server!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
