#!/bin/bash

echo "🔧 Setting up Enhanced Cleanup Scripts"
echo "======================================"

# Make all scripts executable
chmod +x diagnose-aws-resources.sh
chmod +x cleanup-cloudformation.sh
chmod +x verify-complete-cleanup.sh
chmod +x create-eks-cluster.sh
chmod +x delete-eks-cluster.sh

echo "✅ All scripts are now executable"
echo ""

echo "📋 Enhanced Cleanup Process"
echo "=========================="
echo ""
echo "🎯 Your Issue: VPC and networking resources still exist"
echo "💡 Solution: Enhanced cleanup with comprehensive verification"
echo ""

echo "🚀 Step-by-Step Cleanup Process:"
echo "================================"
echo ""

echo "1️⃣ DIAGNOSE CURRENT STATE"
echo "   ./diagnose-aws-resources.sh"
echo "   • Shows all existing healthcare-related AWS resources"
echo "   • Identifies what needs to be cleaned up"
echo "   • Provides cost impact analysis"
echo ""

echo "2️⃣ COMPREHENSIVE CLEANUP"
echo "   ./cleanup-cloudformation.sh"
echo "   • Deletes CloudFormation stacks in correct order"
echo "   • Force deletes stuck EC2 instances"
echo "   • Removes load balancers and waits for completion"
echo "   • Deletes NAT Gateways (cost-saving priority)"
echo "   • Releases Elastic IPs"
echo "   • Comprehensive VPC cleanup:"
echo "     - Network interfaces"
echo "     - Security groups"
echo "     - Subnets"
echo "     - Internet gateways"
echo "     - Route tables"
echo "     - VPCs"
echo "   • Final verification with detailed status"
echo ""

echo "3️⃣ VERIFICATION"
echo "   ./verify-complete-cleanup.sh"
echo "   • Double-checks all resource types"
echo "   • Verifies no cost-generating resources remain"
echo "   • Confirms readiness for new cluster creation"
echo ""

echo "4️⃣ CREATE NEW CLUSTER"
echo "   ./create-eks-cluster.sh"
echo "   • Only run after complete verification passes"
echo ""

echo "⚠️ IMPORTANT NOTES:"
echo "==================="
echo "• The enhanced cleanup script now handles VPC deletion properly"
echo "• It will delete ALL networking components in the correct order"
echo "• NAT Gateways are prioritized for deletion (they cost ~$45/month)"
echo "• The script waits for resources to be fully deleted before proceeding"
echo "• Final verification ensures nothing is left behind"
echo "• If any resources remain, you'll get specific error messages"
echo ""

echo "💰 Cost Impact:"
echo "==============="
echo "• Current issue: VPC resources may be incurring charges"
echo "• After cleanup: $0.00/hour (all resources removed)"
echo "• NAT Gateways are the most expensive component (~$45/month each)"
echo ""

echo "🔧 Troubleshooting:"
echo "==================="
echo "If cleanup fails:"
echo "1. Wait 10-15 minutes for AWS propagation"
echo "2. Re-run ./cleanup-cloudformation.sh"
echo "3. Check AWS Console for stuck resources"
echo "4. Use AWS CLI commands provided in verification output"
echo "5. Contact AWS support for stuck resources"
echo ""

echo "🎯 Ready to start? Run:"
echo "======================="
echo "   ./diagnose-aws-resources.sh"
echo ""
echo "This will show you exactly what needs to be cleaned up!"
