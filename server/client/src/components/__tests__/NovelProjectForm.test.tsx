// server/client/src/components/__tests__/NovelProjectForm.test.tsx

import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import NovelProjectForm from '../NovelProjectForm';
import { Project } from '../../types/novel';

describe('NovelProjectForm', () => {
  const mockOnSubmit = jest.fn();
  const mockOnCancel = jest.fn();

  const defaultProps = {
    onSubmit: mockOnSubmit,
    onCancel: mockOnCancel
  };

  beforeEach(() => {
    mockOnSubmit.mockClear();
    mockOnCancel.mockClear();
  });

  test('renders form elements correctly', () => {
    render(<NovelProjectForm {...defaultProps} />);

    expect(screen.getByLabelText(/项目名称/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/章节数量/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/小说类型/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /创建项目/i })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /取消/i })).toBeInTheDocument();
  });

  test('updates form fields when user types', () => {
    render(<NovelProjectForm {...defaultProps} />);

    const nameInput = screen.getByLabelText(/项目名称/i);
    fireEvent.change(nameInput, { target: { value: '测试小说' } });
    expect(nameInput).toHaveValue('测试小说');

    const chapterCountInput = screen.getByLabelText(/章节数量/i);
    fireEvent.change(chapterCountInput, { target: { value: '20' } });
    expect(chapterCountInput).toHaveValue(20);
  });

  test('submits form with correct data', () => {
    render(<NovelProjectForm {...defaultProps} />);

    fireEvent.change(screen.getByLabelText(/项目名称/i), { target: { value: '我的小说' } });
    fireEvent.change(screen.getByLabelText(/章节数量/i), { target: { value: '50' } });
    fireEvent.change(screen.getByLabelText(/小说类型/i), { target: { value: 'fantasy' } });

    fireEvent.click(screen.getByRole('button', { name: /创建项目/i }));

    expect(mockOnSubmit).toHaveBeenCalledTimes(1);
    const submittedData = mockOnSubmit.mock.calls[0][0] as Omit<Project, 'path' | 'metadata'>;
    
    expect(submittedData.name).toBe('我的小说');
    expect(submittedData.metadata.chapterCount).toBe(50);
    expect(submittedData.metadata.genre).toBe('fantasy');
  });

  test('shows alert when name is empty', () => {
    // 模拟alert函数
    const originalAlert = window.alert;
    window.alert = jest.fn();

    render(<NovelProjectForm {...defaultProps} />);

    // 不填写名称直接提交
    fireEvent.click(screen.getByRole('button', { name: /创建项目/i }));

    expect(window.alert).toHaveBeenCalledWith('请输入项目名称');
    expect(mockOnSubmit).not.toHaveBeenCalled();

    // 恢复原始alert函数
    window.alert = originalAlert;
  });

  test('calls onCancel when cancel button is clicked', () => {
    render(<NovelProjectForm {...defaultProps} />);

    fireEvent.click(screen.getByRole('button', { name: /取消/i }));

    expect(mockOnCancel).toHaveBeenCalledTimes(1);
  });

  test('has default chapter count of 100', () => {
    render(<NovelProjectForm {...defaultProps} />);

    const chapterCountInput = screen.getByLabelText(/章节数量/i);
    expect(chapterCountInput).toHaveValue(100);
  });

  test('restricts chapter count to minimum 1', () => {
    render(<NovelProjectForm {...defaultProps} />);

    const chapterCountInput = screen.getByLabelText(/章节数量/i);
    fireEvent.change(chapterCountInput, { target: { value: '0' } });
    fireEvent.change(chapterCountInput, { target: { value: '-1' } });

    // 注意：在实际应用中，这可能需要更复杂的测试来验证输入限制
    expect(chapterCountInput.getAttribute('min')).toBe('1');
  });
});