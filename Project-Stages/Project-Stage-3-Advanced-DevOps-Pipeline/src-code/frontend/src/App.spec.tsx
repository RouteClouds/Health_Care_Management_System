import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App Component', () => {
  it('renders the app successfully', () => {
    render(<App />)
    // Check for unique text that appears only once
    expect(screen.getByText(/For a Better Tomorrow/i)).toBeDefined()
  })

  it('displays navigation elements', () => {
    render(<App />)
    // Check for elements that exist multiple times using getAllByText
    const doctorLinks = screen.getAllByText(/Find a Doctor/i)
    expect(doctorLinks.length).toBeGreaterThan(0)
    
    const serviceLinks = screen.getAllByText(/Our Services/i)
    expect(serviceLinks.length).toBeGreaterThan(0)
  })

  it('shows authentication buttons', () => {
    render(<App />)
    expect(screen.getByText(/Sign In/i)).toBeDefined()
    expect(screen.getByText(/Sign Up/i)).toBeDefined()
  })
})
